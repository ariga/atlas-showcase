import { Table, Column, Model, Unique, AllowNull, HasMany, DataType, Default } from 'sequelize-typescript';
import { Department } from './Department';

@Table({
    tableName: 'universities',
    timestamps: true,
    paranoid: true,
})
export class University extends Model {
    @AllowNull(false)
    @Column(DataType.STRING(200))
    name!: string;

    @AllowNull(false)
    @Column(DataType.STRING(100))
    location!: string;

    @AllowNull(false)
    @Column(DataType.DATEONLY)
    establishedDate!: Date;

    @HasMany(() => Department, {
        onDelete: 'CASCADE',
        foreignKey: 'universityId',
    })
    departments!: Department[];
}