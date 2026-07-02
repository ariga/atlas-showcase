import { Table, Column, Model, Unique, AllowNull, ForeignKey, BelongsTo, DataType, Default } from 'sequelize-typescript';
import { Department } from './Department';

@Table({
    tableName: 'students',
    timestamps: true,
    paranoid: true,
})
export class Student extends Model {
    @AllowNull(false)
    @Column(DataType.STRING(50))
    firstName!: string;

    @AllowNull(false)
    @Column(DataType.STRING(50))
    lastName!: string;

    @Unique
    @AllowNull(false)
    @Column(DataType.STRING(20))
    studentIdNumber!: string;

    @AllowNull(false)
    @Column(DataType.DATEONLY)
    dateOfBirth!: Date;

    @Unique
    @AllowNull(false)
    @Column(DataType.STRING(255))
    email!: string;

    @AllowNull(false)
    @Default(DataType.NOW)
    @Column(DataType.DATEONLY)
    enrollmentDate!: Date;

    @ForeignKey(() => Department)
    @Column(DataType.INTEGER)
    departmentLink?: number;

    @BelongsTo(() => Department, {
        onDelete: 'SET NULL',
    })
    department?: Department;
}