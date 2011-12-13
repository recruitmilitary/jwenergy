require 'jwenergy/version'
require 'net/https'
require 'ostruct'
require 'date'
require 'nokogiri'

module JWEnergy

  class << self
    attr_accessor :ca_path
  end

  class Job < OpenStruct

    DEFAULT_BASE_URL = 'https://rn12.ultipro.com/JWO1000/JobBoard'
    DEFAULT_INDEX_PATH = '/SearchJobs.aspx?Page=Search'

    def self.all(base_url = DEFAULT_BASE_URL)
      document = fetch_index(base_url + DEFAULT_INDEX_PATH)

      jobs = []

      document.search(".GridTable tr").each_with_index do |row, index|
        next if index == 0 # skip header

        cells = row.search("td")
        next if cells.size < 5 # skip empty rows

        post_date = Date.parse(cells[0].text)
        title = cells[1].text
        city = cells[2].text
        state = cells[3].text
        path = cells[0].at('a').attr('href')
        url = base_url + '/' + path
        path =~ /__ID=\*(.*)/
        internal_id = $1

        jobs << Job.new(:post_date => post_date,
                        :title => title,
                        :city => city,
                        :state => state,
                        :url => url,
                        :internal_id => internal_id)
      end

      jobs
    end

    def self.fetch_index(url)
      attributes = {
        '__PXPOSTBACK' => '1',
        '__PXLBN' => '',
        '__PXLBV' => '',
        'Keywords' => '',
        'Req_TitleFK' => '0',
        'Req_JobFamilyFK' => '0',
        'Req_LocationFK' => '0',
        'Req_City' => '',
        'Req_State' => '',
        'Req_Zip' => '',
        'Radius' => '',
        'RadiusMeasure' => 'mi',
        'RecordsPerPage' => '200',
        'Submit' => 'Submit',
      }

      response = http_post(url, attributes)

      Nokogiri::HTML(response.body)
    end

    def self.http_post(url, attributes)
      http_request(:post, url, attributes)
    end

    def self.http_get(url)
      http_request(:get, url)
    end

    def self.http_request(method, url, attributes = {})
      uri = URI.parse(url)

      case method
      when :get
        request = Net::HTTP::Get.new(uri.path + '?' + uri.query)
      when :post
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data(attributes)

      else
        raise "Unknown HTTP request method #{method}"
      end

      http = Net::HTTP.new(uri.host, uri.port)

      if (uri.port == 443) # ssl?
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_path = ::JWEnergy.ca_path if ::JWEnergy.ca_path
      end

      http.request(request)
    end

    def self.fetch_document(url)
      response = http_get(url)
      Nokogiri::HTML(response.body)
    end

    def description
      document = self.class.fetch_document(url)

      [
        document.at("#DataCell_Req_Description span.PrintVerySmall"),
        document.at("#DataCell_Req_Requirements span.PrintVerySmall")
      ].join
    end

  end

end
