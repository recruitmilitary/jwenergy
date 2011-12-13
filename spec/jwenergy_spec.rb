require 'spec_helper'

describe JWEnergy::Job do

  def read_fixture(name)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}").chomp.gsub(/\n/, "\r\n")
  end

  describe '.all' do
    use_vcr_cassette

    it 'returns a list of jobs' do
      jobs = JWEnergy::Job.all

      jobs.size.should == 68
      job = jobs.first

      job.post_date.should == Date.new(2011, 12, 9)
      job.title.should == 'Pipeline Designer'
      job.city.should == 'Addison'
      job.state.should == 'TX'
      job.url.should == 'https://rn12.ultipro.com/JWO1000/JobBoard/JobDetails.aspx?__ID=*94762A5E73A8D794'
      job.internal_id.should == '94762A5E73A8D794'
      job.description.should == read_fixture('description.html')
    end
  end

end
