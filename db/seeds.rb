puts "🌱 Seeding data..."

# Seed your database here
200.times do
    Student.create(
        first_name: Faker::Student.first_name,
        last_name: Faker::Student.last_name,
        class_year: Faker::Student.class_year,
    )
end

40.times do
    course = Course.create(
        title: Faker::Course.title,
        description: Faker::Course.description,
        department_id: Faker::Course.department_id
    )
end



puts "✅ Done seeding!"
