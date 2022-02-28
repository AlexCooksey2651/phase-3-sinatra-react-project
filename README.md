# OFFICE OF THE REGISTRAR AT POKEMON ACADEMY
## Alex Cooksey, Flatiron School Phase 3 Final Project
### FRONTEND REPO
[View Frontend Resository Here](https://github.com/AlexCooksey2651/phase-3-final-project-course-catalog-frontend)

## Introduction
This app is designed to emulate a page that would be used by a school administrator. The frontend is built with HTML, CSS, and React, while the backend is built with Ruby and Sinatra. 

The Home page gives a brief overview of functionality and helps the user navigate the app. 

Within the Students page, the user can view current students and their information (name, class year, and the 4 courses they are enrolled in along with their corresponding grade in each course). Students can be filtered by class year using a dropdown menu, and/or searched by name. Student information may be edited using the "Edit Student Information" button, and a new student may be added using the "Add New Student" button near the top of the page. Individual students can also be deleted if desired.

The Courses page allows the user to view all current courses; along with the course title, users can read a brief description and see which department the course belongs to. The number of students enrolled is also displayed. Courses can be sorted by name, department, or popularity (i.e. student enrollment); when clicked a second time, the button reverses the sort order.

The Departments page displays each of the five academic departments. Users have the option to click a "Show Course List" button to view all current courses within that particular department.

## Technical Overview

Once you have opened the proper folder folder for the frontend, you can load it in the browswer by typing in `npm start`. You may need to install the `react-router-dom` in order for the navigation bar to work. Specifically, you can use version 5 so that the `Switch` function works (newer versions use `Router` instead) by entering `npm install react-router-dom@5`.

When loading the backend, you can create data from the `seeds.rb` file by running `bundle exec rake db:seed` and get the server up and running by entering `bundle exec rake server`. In order for the frontend to run properly, you'll want this to load on "localhost:9292". Once the server is up and running, data for students may be found at "localhost:9292/students"; course and department data can be seen at analogous endpoints ("/courses" or "/departments").


#### HOME
The home page loads simple HTML text intended to help users navigate the page. 

#### STUDENTS
When selected, the Students page loads the `StudentContainer.js` component. At the top, this loads:
    - An input field to allow users to search students by name
    - A dropdown menu that allows users to filter students by class year (or view all)
    - An "Add New Student" button that allows a form to be conditionally rendered. When filled out, this form allows another student to be added to the display.

The `StudentContainer` component is responsible for rendering "Student Cards" (i.e. the `Student` component) based on user input. 

The entire collection of students in the database is retrieved on page load as follows: 
```
useEffect(() => {
    fetch('http://localhost:9292/students')
        .then(response => response.json())
        .then(students => setStudents(students))
}, [])
```

On the backend, this corresponds to the following `get` request in the `app/controllers/application_controller.rb` file: 
```
get '/students' do
    students = Student.order(class_year: :asc, last_name: :asc)
    students.to_json(only: [:id, :first_name, :last_name, :class_year], include: { 
        student_courses: { only: [:grade], include: {
            course: { only: [:title] }
        } } 
    })
end
```

If a user clicks the "Add New Student" button, fills out the form, and submits it, a post request is triggered to add this student to the collection. This is handled in the `AddStudentForm` component: 
```
const [firstName, setFirstName] = useState("")
  const [lastName, setLastName] = useState("")
  const [classYear, setClassYear] = useState("")

  const body = {
      first_name: firstName,
      last_name: lastName,
      class_year: classYear
  }

  function addNewStudent(event) {
    event.preventDefault()
    fetch("http://localhost:9292/students", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    })
        .then(response => response.json())
        .then(newStudent => {
            handleNewStudent(newStudent);
        });
    setFirstName("");
    setLastName("");
    setClassYear("")
}
```

In the backend `application_contoller` file, this is handled with the following route:
```
post '/students' do
    student = Student.create(
      first_name: params[:first_name],
      last_name: params[:last_name],
      class_year: params[:class_year]
    )
    student.to_json
end
```

On the frontend, the user should be able to view the courses students are enrolled in and their corresponding grade in each course, therefore the get request must retrieve information from other database tables. The `student_courses` table represents the join table creating the "many-to-many" relationship between students and courses, and contains the `grade` information for each student-course relationship.

To filter students by class year, a variable - `filteredStudents` is declared as an arrow function as shown below:
```
const filteredStudents = () => {
    if (selectedYear !== "") {
        const singleClass = students.filter(student => {
            return student.class_year === parseInt(selectedYear)
        })
        return singleClass
    } else { 
        return students
    }
}
```

If the "All" selection is made, the original collection of students is rendered; otherwise, only students with the proper class year are returned. 
The functionality for the search bar is built like so: 

```
const searchedStudents = filteredStudents().filter(student => {
    if (student.first_name.toLowerCase().includes(searchText.toLowerCase()) || student.last_name.toLowerCase().includes(searchText.toLowerCase())) {
            return student
    }
})
``` 

This allows students to search by first or last name, and also ensures that the search is not case-sensitive. `searchText` is a variable that lives in state and corresponds to the content of the input field. By manipulating the array corresponding to `filteredStudents()` instead of the original `students` variable that lives in state, we allow users to perform the search and filter functions simultaenously. 

Ultimately, student cards are then rendered by mapping over the `searchedStudents` array. 

Finally, the `StudentContainer` component owns the functionality to update the `students` variable in state after a user has edited student information, deleted a student, or added a new student. 

The `Student` component houses the `delete` request that is executed if a user clicks the `Delete Student` button:
```
function handleDeleteStudent(event) {
    fetch(`http://localhost:9292/students/${id}`, {
        method: "DELETE",
    })
    onDeleteStudent(id)
}
```

The `id` variable is taken from the `student` variable, an object representing an individual student, which has been passed down as props from the `StudentContainer` file. 

On the backend, the `application_contoller` file handles this request as follows: 
```
 delete '/students/:id' do
    student = Student.find(params[:id])
    student.destroy
    student.to_json
end
```

If a user clicks the "Edit Student Information" button, a form (housed in the `EditStudentForm` component) is rendered. The form can be hidden again by reclicking this same button. If the form is submitted, a `patch` request is triggered to update the student information on the backend. 
```
function handleEditStudent(event) {
    event.preventDefault()
    fetch(`http://localhost:9292/students/${id}`, {
        method: "PATCH",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    })
        .then(response => response.json())
        .then(updatedStudent => {
            onEditStudent(updatedStudent)
        })
}
```

The corresponding backend route is as follows: 
```
patch '/students/:id' do
    student = Student.find(params[:id])
    student.update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      class_year: params[:class_year]
    )
    student.to_json
end
```

#### COURSES
The collection of courses is rendered in a fashion similar to the collection of students. 

Clicking "Courses" in the nav bar loads the `CourseContainer` component, which loads all courses with a `get` request:
```
useEffect(() => {
    fetch('http://localhost:9292/courses')
        .then(response => response.json())
        .then(courses => setCourses(courses))
}, [])
```

On the backend: 
```
get '/courses' do
    courses = Course.order(:title)
    courses.to_json(only: [:id, :title, :description], include: {
      department: { only: [:name] }, 
      student_courses: { only: [:student_id] }
    })    
end
```

Note that the get request dictates that by default, courses load already alphabetized by title (in A-Z order). 

Three different buttons are shown, each corresponding to a different sorting option - Name, Department, or Popularity. Here we see the "Sort by Department" code as an example:
```
function CourseContainer() {
    const [deptOrder, setDeptOrder] = useState(true)

    ...

    function sortByDepartment() {
        const sortedCourses = [...courses].sort((a, b) => {
            let deptA = a.department.name
            let deptB = b.department.name
            if (deptOrder === true) {
                if (deptA < deptB) {
                    return -1
                } else if (deptA > deptB) {
                    return 1
                }
                return 0
            } else if (deptOrder === false) {
                if (deptA < deptB) {
                    return 1
                } else if (deptA > deptB) {
                    return -1
                }
                return 0
            }
        })
        setDeptOrder(!deptOrder)
        setCourses(sortedCourses)
    }
}
```

The `deptOrder` variable in state allows a binary decision of whether or order the courses in ascending or descending order. The `sortByDepartment` function sorts courses based on the department name, in A-Z order if the `deptOrder` is set to `true` and Z-A order if `false`. To ensure reversibility, state is updated to switch `deptOrder` and updates the courses so that the courses are rendered in the correct order (handled by a map method that creates Course cards).

The "Sort By Name" and "Sort By Popularity" buttons function in the same way.

Each `courseCard` - contained in the `Course` component - houses an "Edit Course Description" button that, when clicked, displays a form to update the `description` key of the `course` object. This form and its corresponding patch request and backend route are essentially identical to the "Edit Student Information" functionality on the Students page. 

#### DEPARTMENTS
On page load, the collection of departments is retrieved with a familiar `get` request; in order to retrieve each departments' courses, the backend route has to provide the matching courses through the `include` command.

Frontend:
```
const [departments, setDepartments] = useState([])
    
useEffect(() => {
fetch('http://localhost:9292/departments')
        .then(response => response.json())
        .then(departments => setDepartments(departments))
}, [])
```

Backend:
```
get '/departments' do
    departments = Department.order(:name)
    departments.to_json(only: [:id, :name], include: {
      courses: { only: [:title] }
    })
end
```









