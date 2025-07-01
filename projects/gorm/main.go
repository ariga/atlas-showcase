package gorm

import (
	"time"

	"gorm.io/gorm"
)

// University model
type University struct {
	gorm.Model
	Name            string       `gorm:"type:varchar(200);unique;not null"`
	ShortName       string       `gorm:"type:varchar(10);unique;not null"`
	Location        string       `gorm:"type:varchar(100);not null"`
	EstablishedDate time.Time    `gorm:"type:date"`
	Departments     []Department // One-to-Many relationship: A University has many Departments
}

// Department model
type Department struct {
	gorm.Model
	Name             string     `gorm:"type:varchar(100);unique;not null"`
	HeadOfDepartment string     `gorm:"type:varchar(100)"`
	UniversityID     uint       `gorm:"not null"`
	University       University `gorm:"constraint:OnDelete:CASCADE"`
	Students         []Student  // One-to-Many relationship: A Department has many Students
}

// Student model
type Student struct {
	gorm.Model
	FirstName       string    `gorm:"type:varchar(50);not null"`
	LastName        string    `gorm:"type:varchar(50);not null"`
	StudentIDNumber string    `gorm:"type:varchar(20);unique;not null"`
	DateOfBirth     time.Time `gorm:"type:date"`
	Email           string    `gorm:"type:varchar(255);unique;not null"`
	EnrollmentDate  time.Time `gorm:"autoCreateTime;type:date"`
	DepartmentID    *uint
	Department      *Department `gorm:"constraint:OnDelete:SET NULL;"` // Belongs-to relationship, SET NULL on delete
}
