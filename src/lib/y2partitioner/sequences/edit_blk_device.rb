require "yast"
require "ui/sequence"
require "y2partitioner/device_graphs"
require "y2partitioner/dialogs/partition_size"
require "y2partitioner/dialogs/partition_type"
require "y2partitioner/dialogs/encrypt_password"
require "y2partitioner/format_mount/base"

Yast.import "Wizard"

module Y2Partitioner
  module Sequences
    # BlkDevice edition
    class EditBlkDevice < UI::Sequence
      include Yast::Logger
      # @param partition [Y2Storage::BlkDevice]
      def initialize(partition)
        textdomain "storage"
        @options = FormatMount::Options.new(partition: partition)
        @partition = partition
      end

      def run
        sequence_hash = {
          "ws_start"       => "format_options",
          "format_options" => { next: "password" },
          "password"       => { next: "format_mount" },
          "format_mount"   => { finish: :finish }
        }

        sym = nil
        DeviceGraphs.instance.transaction do
          sym = wizard_next_back do
            super(sequence: sequence_hash)
          end
          sym == :finish
        end

        sym
      end

      # FIXME: move to Wizard
      def wizard_next_back(&block)
        Yast::Wizard.OpenNextBackDialog
        block.call
      ensure
        Yast::Wizard.CloseDialog
      end

      def format_options
        @format_dialog ||= Dialogs::FormatAndMount.new(@options)

        @format_dialog.run
      end

      def password
        return :next unless @options.encrypt
        @encrypt_dialog ||= Dialogs::EncryptPassword.new(@options)

        @encrypt_dialog.run
      end

      def format_mount
        FormatMount::Base.new(@partition, @options).apply_options!

        :finish
      end
    end
  end
end
