import * as path from 'path';
import { Options } from 'sequelize';
const config = require('./src/config/config');

const env = process.env.NODE_ENV || 'development';
const dbConfig: Options = config[env];

module.exports = {
    migrations: {
        glob: path.join(__dirname, 'src', 'migrations', '*.ts'),
    },
    models: {
        glob: path.join(__dirname, 'src', 'models', '*.ts'),
    },
    ...dbConfig,
};