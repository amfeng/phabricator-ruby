require_relative '_lib'

module PhabricatorTests::Unit
  class TaskTest < Test
    include Phabricator
    include Phabricator::Maniphest

    it 'accesses raw props and name_props' do
      task = Task.new(
        title: 'foo',
        description: 'bar',
        priority: 50,
        projectPHIDs: ['phid1']
      )
      assert_equal('foo', task.title)
      assert_equal('bar', task.description)
      assert_equal(50, task.priority)
      assert_equal(['phid1'], task.projectPHIDs)
      assert_equal('normal', task.priorityName)
    end

    it 'creates with raw props and name_props' do
      Project.expects(:raw_value_from_name).with('project1').returns('pphid')
      User.expects(:raw_value_from_name).with('owner1').returns('ophid')

      Project.client.expects(:request).with(
        :post,
        "maniphest.createtask",
        {
          priority: 80,
          projectPHIDs: ['pphid'],
          ownerPHID: 'ophid',
          ccPHIDs: ['ccphid'],
        }
      ).returns('result' => {})

      Task.create(
        priorityName: 'high',
        projectNames: ['project1'],
        ownerName: 'owner1',
        ccPHIDs: ['ccphid'],
      )
    end

    it 'queries with raw props and name_props' do
      Project.expects(:raw_value_from_name).with('project1').returns('pphid')
      User.expects(:raw_value_from_name).with('owner1').returns('ophid')

      Project.client.expects(:request).with(
        :post,
        "maniphest.query",
        {
          priority: 80,
          projectPHIDs: ['pphid'],
          ownerPHIDs: ['ophid'],
          ccPHIDs: ['ccphid'],
        }
      ).returns('result' => {})

      Task.query(
        priorityName: 'high',
        projectNames: ['project1'],
        ownerNames: ['owner1'],
        ccPHIDs: ['ccphid'],
      )
    end

  end
end
