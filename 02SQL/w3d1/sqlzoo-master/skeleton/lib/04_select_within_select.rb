# == Schema Information
#
# Table name: world
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

def example_select_with_subquery
  execute(<<-SQL)
    SELECT
      name
    FROM
      world
    WHERE
      population > (
        SELECT
          population
        FROM
          world
        WHERE
          name='Romania'
        )
  SQL
end

def larger_than_russia
  # List each country name where the population is larger than 'Russia'.
  execute(<<-SQL)
  SELECT
    name
  FROM
    world
  WHERE
    population > (
      SELECT
        population
      FROM
        world
      WHERE
        name = 'Russia'
    )
  SQL
end

def richer_than_england
  # Show the countries in Europe with a per capita GDP greater than
  # 'United Kingdom'.
  execute(<<-SQL)
  SELECT
  name
  FROM
  world
  WHERE
  continent = 'Europe' AND gdp / population > (SELECT
                                                gdp / population
                                               FROM
                                                 world
                                               WHERE
                                                 name = 'United Kingdom'
                                              )
  SQL
end

def neighbors_of_b_countries
  # List the name and continent of countries in the continents containing
  # 'Belize', 'Belgium'.
  execute(<<-SQL)
  SELECT
  name, continent
  FROM
  world
  WHERE
  continent IN (SELECT -- useful to use "IN " rather than list out multiple conditionals
                continent
               FROM
                world
               WHERE
                name = 'Belize' OR name = 'Belgium')
  SQL
end

def population_constraint
  # Which country has a population that is more than Canada but less than
  # Poland? Show the name and the population.
  execute(<<-SQL)
  SELECT
  name, population
  FROM
  world
  WHERE
  population BETWEEN (SELECT
                       population + 1
                      FROM
                        world
                      WHERE
                        name = 'Canada')
             AND (SELECT
                    population - 1
                  FROM
                    world
                  WHERE
                    name = 'Poland')
                    -- Can also do less than or greater than
  SQL
end

# To get a well rounded view of the important features of SQL you should move
# on to the next tutorial concerning aggregates.

# To gain an absurdly detailed view of one insignificant feature of the
# language, read on.

# We can use the word ALL to allow >= or > or < or <=to act over a list.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
  SELECT
    world.name
  FROM
    world,
    (SELECT
      gdp
    FROM
      world
    WHERE
      continent = 'Europe') AS e
  GROUP BY
    world.name
  HAVING
    world.gdp > MAX(e.gdp)

  SQL
end

# We can refer to values in the outer SELECT within the inner SELECT. We can
# name the tables so that we can tell the difference between the inner and
# outer versions.

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
  SELECT
    w1.continent, w1.name, w1.area
  FROM
    world w1
  WHERE
    w1.area = (SELECT
        MAX(area)
      FROM
        world w2
      WHERE
        w1.continent = w2.continent
      )
  SQL
end

# BONUS QUESTIONS: these are difficult questions that utilize techniques not
# covered in prior sections:

def sparse_continents
  # Find each country that belongs to a continent where all populations are
  # less than 25,000,000. Show name, continent and population.
  execute(<<-SQL)
  SELECT
  name, continent, population
  FROM
  world w1
  WHERE
  25000000 >
  (SELECT
    MAX(population)
    FROM
    world w2
    WHERE
    w1.continent = w2.continent
  )

  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)
  SELECT
  name, continent
  FROM
  world w1
  WHERE
  w1.population >
  3*(SELECT
    MAX(population)
    FROM
    world w2
    WHERE
    w1.continent = w2.continent AND w2.name != w1.name
  )
  SQL
end
