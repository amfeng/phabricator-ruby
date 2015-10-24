require 'phabricator/conduit_client'

module Phabricator
  class PhabObject
    def self.inherited(other)
      other.instance_eval do
        @props = {}
        @translatable_prop_names = []

        prop :phid
        attr_accessor :attrs
      end
    end

    def self.prop(prop_sym, opts={})
      @props[prop_sym] = opts
      # For now, make props read-only, since we don't provide a method to save a changed object
      define_method(prop_sym) {@attrs[prop_sym]}

      name_prop = opts[:name_prop]
      if name_prop
        klass = opts[:class]
        unless klass
          raise ArgumentError.new("class is required when name_prop is provided")
        end
        @translatable_prop_names << prop_sym
        define_method(name_prop) do
          val = send(prop_sym)
          if val.is_a?(Array)
            val.map {|v| klass.name_from_raw_value(v)}
          else
            klass.name_from_raw_value(val)
          end
        end
      end
    end

    def self.props
      @props
    end

    def self.translatable_props
      @translatable_prop_names.map {|prop_sym| [prop_sym, @props[prop_sym]]}
    end

    def initialize(attributes)
      # Convert all keys to symbols
      @attrs = Hash[attributes.map {|(k,v)| [k.to_sym, v]}]
      if @attrs.length != attributes.length
        raise ArgumentError.new("attributes must not contain string and symbol keys of the same value")
      end
    end

    def self.api_name
      self.name.split('::').last.downcase
    end

    def self.create_verb
      'create'
    end

    def self.translate_name_props(attributes, is_query:)
      attributes = attributes.dup
      translatable_props.each do |prop, prop_opts|
        name_prop = prop_opts.fetch(:name_prop)
        if is_query
          prop = prop_opts.fetch(:query_prop, prop)
          name_prop = prop_opts.fetch(:query_name_prop, name_prop)
        end
        next unless attributes.key?(name_prop)

        if attributes.key?(prop)
          raise ArgumentError.new("Cannot include both #{prop} and #{name_prop}")
        end

        attr_val = attributes.delete(name_prop)
        klass = prop_opts.fetch(:class)
        if attr_val.is_a?(Array)
          attributes[prop] = attr_val.map {|name| klass.raw_value_from_name(name)}
        else
          attributes[prop] = klass.raw_value_from_name(attr_val)
        end
      end
      attributes
    end

    def self.create(attributes={})
      attributes = translate_name_props(attributes, is_query: false)
      response = client.request(:post, "#{api_name}.#{create_verb}", attributes)
      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def update(attributes)
      attributes = self.class.translate_name_props(attributes, is_query: false)
      if attributes.key?(:id)
        raise ArgumentError.new("id is not allowed for update (it's automatically included)")
      end
      attributes[:id] = id

      response = self.class.client.request(:post, "#{self.class.api_name}.update", attributes)
      data = response['result']

      # TODO: Error handling

      self.class.new(data)
    end

    def self.query(attributes={})
      attributes = translate_name_props(attributes, is_query: true)
      response = client.request(:post, "#{api_name}.query", attributes)
      items = response['result']

      # Phab is horrible; some endpoints put use a 'data' subhash, some don't
      if items.is_a?(Hash) && items.key?('data')
        items = items['data']
      end

      # Phab is even more horrible; some endpoints return an array, some index by phid
      if items.is_a?(Hash)
        items = items.values
      end

      items.map {|item| self.new(item)}
    end

    def self.lookup_project_phid(project_name)
      Phabricator.lookup_project(project_name).phid
    end

    def self.lookup_user_phid(user_name)
      Phabricator.lookup_user(user_name).phid
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
