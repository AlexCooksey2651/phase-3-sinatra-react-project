class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'
  
  # Add your routes here
  # get "/" do
  #   { message: "Good luck with your project!" }.to_json
  # end

  get '/students' do
    students = Student.order(class_year: :asc, last_name: :asc)
    students.to_json(only: [:id, :first_name, :last_name, :class_year], include: { 
      student_courses: { only: [:grade], include: {
         course: { only: [:title] }
      } } 
    })
  end

  get '/courses' do
    courses = Course.order(:title)
    courses.to_json(only: [:id, :title, :description], include: {
      department: { only: [:name] }
    })
  end

  get '/departments' do
    departments = Department.order(:name)
    departments.to_json(only: [:id, :name], include: {
      courses: { only: [:title] }
    })
  end

end
