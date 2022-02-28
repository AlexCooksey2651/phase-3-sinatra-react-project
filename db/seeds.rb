require 'faker'

puts "🌱 Seeding data..."

# Seed your database here
200.times do
    Student.create(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        class_year: rand(2022..2025)
    )
end

Department.create(name: "Math")
Department.create(name: "Biology")
Department.create(name: "English")
Department.create(name: "Politics")
Department.create(name: "History")

Department.all.each do |department|
    3.times do
        department.courses.create(
            title: Faker::Educator.course_name,
            description: "This is a class"
        )
    end
end

Student.all.each do |student|
    4.times do
        student.student_courses.create(
            grade: rand(60..100),
            course_id: Course.all.sample.id
        )
    end
end

puts "✅ Done seeding!"
