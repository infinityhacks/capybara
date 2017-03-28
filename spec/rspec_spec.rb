# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'capybara/rspec', :type => :feature do
  it "should include Capybara in rspec" do
    visit('/foo')
    expect(page.body).to include('Another World')
  end

  it "should include RSpec matcher proxies" do
    expect(self.class.ancestors).to include Capybara::RSpecMatcherProxies
  end

  context "resetting session" do
    it "sets a cookie in one example..." do
      visit('/set_cookie')
      expect(page.body).to include('Cookie set to test_cookie')
    end

    it "...then it is not available in the next" do
      visit('/get_cookie')
      expect(page.body).not_to include('test_cookie')
    end
  end

  context "setting the current driver" do
    it "sets the current driver in one example..." do
      Capybara.current_driver = :selenium
    end

    it "...then it has returned to the default in the next example" do
      expect(Capybara.current_driver).to eq(:rack_test)
    end
  end

  it "switches to the javascript driver when giving it as metadata", js: true do
    expect(Capybara.current_driver).to eq(Capybara.javascript_driver)
  end

  it "switches to the given driver when giving it as metadata", :driver => :culerity do
    expect(Capybara.current_driver).to eq(:culerity)
  end

  context "#all" do
    it "allows access to the Capybara finder" do
      visit('/with_html')
      expect(all(:css, 'h2.head').size).to eq(5)
    end

    it "allows access to the RSpec matcher" do
      skip "RSpec < 3 doesn't have an `all` matcher" if rspec2?

      visit('/with_html')
      expect(["test1", "test2"]).to all(be_a(String))
    end
  end

  context "#within" do
    it "allows access to the Capybara scoper" do
      visit('/with_html')
      expect do
        within(:css, "#does_not_exist") { click_link "Go to simple" }
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "allows access to the RSpec matcher" do
      skip "RSpec version doesn't have a 'within' matcher" unless ::RSpec::Matchers.instance_methods.include?(:within)
      visit('/with_html')
      # This reads terribly, but must call #within
      expect(find(:css, 'span.number').text.to_i).to within(1).of(41)
    end
  end
end

RSpec.describe 'capybara/rspec', :type => :other do
  context "when RSpec::Matchers is included after Capybara::DSL" do
    before do
      include Capybara::DSL
      include RSpec::Matchers
    end

    context "#all" do
      it "should raise when non-matcher passed" do
        skip "RSpec version doesn't have an `all` matcher" unless ::RSpec::Matchers.instance_methods.include?(:all)
        expect do
          all("div")
        end.to raise_error(/make sure Capybara::DSL is included after RSpec::Matchers/)
      end

      it "should not raise when matcher passed" do
        skip "RSpec version doesn't have an `all` matcher" unless ::RSpec::Matchers.instance_methods.include?(:all)
        expect([2,4]).to all(be_even)
      end
    end

    context "#within" do
      it "should raise when block passed to #within" do
        skip "RSpec version doesn't have a 'within' matcher" unless ::RSpec::Matchers.instance_methods.include?(:within)
        expect do
          within('.div'){}
        end.to raise_error(/make sure Capybara::DSL is included after RSpec::Matchers/)
      end

      it "should not raise when no block passed to #within" do
        skip "RSpec version doesn't have a 'within' matcher" unless ::RSpec::Matchers.instance_methods.include?(:within)
        expect(3).to within(1).of(4)
      end
    end
  end
end

RSpec.describe 'capybara/rspec', :type => :other do
  it "should not include Capybara" do
    expect { visit('/') }.to raise_error(NoMethodError)
  end
end

feature "Feature DSL" do
  scenario "is pulled in" do
    visit('/foo')
    expect(page.body).to include('Another World')
  end
end
