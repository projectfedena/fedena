namespace :db do

  desc "load user data from csv"
  task :load_csv_task  => :environment do

    require 'fastercsv'

    FasterCSV.foreach("excel.csv") do |row|

      s = Student.new(
        :admission_no => row[0],
        :roll_no => row[1],     # class roll no.
        :admission_date => row[2],

        :first_name => row[3],
        :middle_name => row[4],
        :last_name => row[5],

        :course_id => row[6],
        :date_of_birth => row[7],
        :gender => row[8],
        :blood_group => row[9],
        :birth_place => row[10],
        :nationality_id => row[11],
        :language => row[12],
        :religion => row[13],
        :category => row[14],

        :address => row[15],
        :city => row[16],
        :state => row[17],
        :pin_code => row[18],
        :country_id => row[19],

        :phone1 => row[20],
        :phone2 => row[21],
        :email => row[22],
        :photo_filename => row[23],
        :photo_content_type => row[24],
        :photo_data => row[25],
        :status => row[26],
        :status_description => row[27],
        :immediate_contact_id => row[28]
      )

      unless s.save
        puts "Error"
      end

    end
  end
end
