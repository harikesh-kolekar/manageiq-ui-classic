describe ApplicationController, "#Timelines" do
  describe EmsInfraController do
    context "#tl_chooser" do
      before do
        @ems = FactoryGirl.create(:ems_openstack_infra)
        controller.instance_variable_set(:@tl_options,
                                         ApplicationController::Timelines::Options.new)
      end

      it "resets timeline options correctly when apply button is pressed" do
        options            = assigns(:tl_options)
        dt                 = Time.zone.now
        options.date       = ApplicationController::Timelines::DateOptions.new
        options.date.end   = dt
        options.date.start = dt

        controller.instance_variable_set(:@_params, :id => @ems.id, :tl_show => "policy_timeline")
        expect(controller).to receive(:render)

        expect(options.date[:start]).to eq(dt)
        expect(options.date[:end]).to eq(dt)

        controller.send(:tl_chooser)

        options = assigns(:tl_options)
        expect(options.date[:start]).to eq(nil)
        expect(options.date[:end]).to eq(nil)
      end

      it "sets categories for policy timelines correctly" do
        controller.instance_variable_set(:@_params,
                                         :id            => @ems.id,
                                         :tl_show       => "policy_timeline",
                                         :tl_categories => ["VM Operation"])
        expect(controller).to receive(:render)
        controller.send(:tl_chooser)
        options = assigns(:tl_options)
        expect(options.policy[:categories]).to include('VM Operation')
      end

      it "selecting critical option of the selectpicker in the timeline should append them to events filter list" do
        controller.instance_variable_set(:@_params,
                                         :id            => @ems.id,
                                         :tl_show       => "timeline",
                                         :tl_levels     => ["critical"],
                                         :tl_categories => ["Power Activity"])
        expect(controller).to receive(:render)
        controller.send(:tl_chooser)
        options = assigns(:tl_options)
        expect(options.management[:categories][:power][:include_set]).to include('AUTO_FAILED_SUSPEND_VM')
        expect(options.management[:categories][:power][:include_set]).to_not include('PowerOffVM_Task')
      end

      it "selecting details option of the selectpicker in the timeline should append them to events filter list" do
        controller.instance_variable_set(:@_params,
                                         :id            => @ems.id,
                                         :tl_show       => "timeline",
                                         :tl_levels     => ["detail"],
                                         :tl_categories => ["Power Activity"])
        expect(controller).to receive(:render)
        controller.send(:tl_chooser)
        options = assigns(:tl_options)
        expect(options.management[:categories][:power][:include_set]).to_not include('AUTO_FAILED_SUSPEND_VM')
        expect(options.management[:categories][:power][:include_set]).to include('PowerOffVM_Task')
      end

      it "selecting two options of the selectpicker in the timeline should append both to events filter list" do
        controller.instance_variable_set(:@_params,
                                         :id            => @ems.id,
                                         :tl_show       => "timeline",
                                         :tl_levels     => %w(critical detail),
                                         :tl_categories => ["Power Activity"])
        expect(controller).to receive(:render)
        controller.send(:tl_chooser)
        options = assigns(:tl_options)
        expect(options.management[:categories][:power][:include_set]).to include('AUTO_FAILED_SUSPEND_VM')
        expect(options.management[:categories][:power][:include_set]).to include('PowerOffVM_Task')
      end
    end
  end
end
