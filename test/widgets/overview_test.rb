require_relative "../test_helper"

require "cwm/rspec"
require "y2partitioner/device_graphs"
require "y2partitioner/widgets/overview"

describe Y2Partitioner::Widgets::OverviewTreePager do
  subject do

    smanager = Y2Storage::StorageManager.instance
    system = smanager.y2storage_probed
    current = smanager.y2storage_staging
    Y2Partitioner::DeviceGraphs.create_instance(system, current)
    described_class.new(current)
  end

  include_examples "CWM::Pager"
end
