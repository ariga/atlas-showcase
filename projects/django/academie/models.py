from django.db import models

class University(models.Model):
    name = models.CharField(max_length=200)
    location = models.CharField(max_length=100)
    established_date = models.DateField()

    def __str__(self):
        return self.name

class Department(models.Model):
    name = models.CharField(max_length=100, unique=True)
    head_of_department = models.CharField(max_length=100, blank=True, null=True)
    university = models.ForeignKey(University, on_delete=models.CASCADE, null=True, related_name='departments')
    # A Department belongs to one University

    def __str__(self):
        return f"{self.name} ({self.university.name})"

class Student(models.Model):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    student_id_number = models.CharField(max_length=20, unique=True)
    date_of_birth = models.DateField()
    email = models.EmailField(unique=True)
    enrollment_date = models.DateField(auto_now_add=True) # Automatically sets the date when student is created
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True, related_name='students', db_column="department_link")
    # A Student belongs to one Department (optional)
    # If a Department is deleted, student's department field is set to NULL

    class Meta:
        ordering = ['last_name', 'first_name'] # Default ordering for query results

    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.student_id_number})"