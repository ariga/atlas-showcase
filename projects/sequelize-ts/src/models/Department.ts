import { Table, Column, Model, Unique, AllowNull, ForeignKey, BelongsTo, HasMany, DataType, Default } from 'sequelize-typescript';
import { University } from './University';
import { Student } from './Student';

@Table({
    tableName: 'departments',
    timestamps: true,
    paranoid: true,
})
export class Department extends Model {
    @Unique
    @AllowNull(false)
    @Column(DataType.STRING(100))
    name!: string;

    @Column(DataType.STRING(100))
    headOfDepartment?: string;

    @ForeignKey(() => University)
    @AllowNull(false)
    @Column(DataType.INTEGER)
    universityId!: number;

    @BelongsTo(() => University, {
        onDelete: 'CASCADE',
    })
    university?: University;

    @HasMany(() => Student, {
        onDelete: 'SET NULL',
        foreignKey: 'departmentId',
    })
    students!: Student[];
}