class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'

  get '/students' do
    students = Student.order(class_year: :asc, last_name: :asc)
    students.to_json(only: [:id, :first_name, :last_name, :class_year], include: { 
      student_courses: { only: [:grade], include: {
         course: { only: [:title] }
      } } 
    })
  end

  patch '/students/:id' do
    student = Student.find(params[:id])
    student.update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      class_year: params[:class_year]
    )
    student.to_json(only: [:id, :first_name, :last_name, :class_year], include: { 
      student_courses: { only: [:grade], include: {
         course: { only: [:title] }
      } } 
    })
  end

  post '/students' do
    student = Student.create(
      first_name: params[:first_name],
      last_name: params[:last_name],
      class_year: params[:class_year]
    )
    student.to_json
  end

  delete '/students/:id' do
    student = Student.find(params[:id])
    student.destroy
    student.to_json
  end

  get '/courses' do
    courses = Course.order(:title)
    courses.to_json(only: [:id, :title, :description], include: {
      department: { only: [:name] }, 
      student_courses: { only: [:student_id] }
    })    
  end
  

  patch '/courses/:id' do
    course = Course.find(params[:id])
    course.update(
      description: params[:description]
    )
    course.to_json(include: [:student_courses, :department])
  end

  get '/departments' do
    departments = Department.order(:name)
    departments.to_json(only: [:id, :name], include: {
      courses: { only: [:title] }
    })
  end

end
