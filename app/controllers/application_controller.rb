class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'
  
  # Add your routes here
  # get "/" do
  #   { message: "Good luck with your project!" }.to_json
  # end

  get '/students' do
    students = Student.order(class_year: :asc, last_name: :asc)
    students.to_json(include: :courses)
  end

  get '/courses' do
    courses = Course.order(:title)
    courses.to_json(include: :department)
  end

  get '/departments' do
    departments = Department.order(:name)
    departments.to_json(include: :courses)
  end

end
