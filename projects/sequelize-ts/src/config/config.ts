import { Options } from 'sequelize';

interface DbConfig {
  [env: string]: Options;
}

const config: DbConfig = {
  development: {
    dialect: 'sqlite',
    storage: './database.sqlite',
    logging: console.log,
  },
  test: {
    dialect: 'sqlite',
    storage: ':memory:',
  },
  production: {
    dialect: 'sqlite',
    storage: './database.sqlite',
    logging: false,
  },
};

export = config;