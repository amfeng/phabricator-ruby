require File.expand_path('../../_lib', __FILE__)

module PhabricatorTests::Unit
  class Test < PhabricatorTests::Test
    before do
      Phabricator::ConduitClient.stubs(:new => mock)
    end
  end
end
