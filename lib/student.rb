require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end
  def self.create_table
    sql =  <<-SQL
    CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql =  <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create
    student = Student.new(name, grade)
    student.save
    student
  end
  def self.new_from_db(row:,id:,name:,grade:)
    # create a new Student object given a row from the database
    new_student = self.new  # self.new is the same as running Song.new
    new_student.id = row[0]
    new_student.name =  row[1]
    new_student.grade = row[2]
    new_student # return the newly created instance
  end

  def self.find_by_name(id,name,grade)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  def update(id,name,grade)
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
