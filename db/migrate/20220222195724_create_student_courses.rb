class CreateStudentCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :student_courses do |t|
      t.integer :grade
      t.integer :student_id
      t.integer :course_id
      t.timestamps
    end
  end
end
