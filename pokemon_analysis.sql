
WITH all_pokemon_data AS (
  -- this CTE is used to combine all 6 different Pokemon sets Data.
  SELECT 
    'BlackBolt' as set_name,
    name,
    avgPrice,
    marketPrice,
    extCardType,
    extNumber
  FROM `pokemondata-469422.pokemonSet.BlackBolt`

  UNION ALL 
  SELECT 
    'WhiteFlare' as set_name,
    name,
    avgPrice,
    marketPrice,
    extCardType,
    extNumber
  FROM `pokemondata-469422.pokemonSet.whiteFlare`

  UNION ALL
  SELECT 
    'Destined Rivals' as set_name,
    name,
    avgPrice,
    marketPrice,
    extCardType,
    extNumber
  FROM `pokemondata-469422.pokemonSet.destinedRivals`

  UNION ALL
  SELECT
    'Prismatic Evolutions' as set_name,
    name, 
    avgPrice,
    marketPrice,
    extCardType,
    extNumber
  FROM `pokemondata-469422.pokemonSet.prismaticEvolutions`

  UNION ALL
  SELECT
    'Evolving Skies' as set_name,
    name,
    avgPrice,
    marketPrice,
    extCardType,
    extNumber
  FROM `pokemondata-469422.pokemonSet.evolvingSkies`

  UNION ALL
  SELECT
    'Fusion Strike' as set_name,
    name,
    avgPrice,
    marketPrice,
    extCardType,
    extNumber
  FROM `pokemondata-469422.pokemonSet.fusionStrike`
),

ranked_cards AS (
  SELECT
    set_name,
    name,
    avgPrice,
    marketPrice,
    extCardType,
    -- used ROW_NUMBER() to get a fixed number of ranked cards for each set.
    ROW_NUMBER() OVER (PARTITION BY set_name ORDER BY SAFE_CAST(marketPrice AS FLOAT64) DESC) AS card_ranking
  FROM
    all_pokemon_data
  WHERE
    -- used extNumber to make sure cards are only pulled. Cards are the only item that contain an extNumber, which is why I also use IS NOT NULL.
    extNumber IS NOT NULL AND TRIM(extNumber) != '' AND marketPrice IS NOT NULL AND marketPrice > 0
)

-- This final SELECT statement combines the Elite Trainer Boxes and the top 10 cards.
SELECT
  set_name,
  name,
  avgPrice,
  marketPrice,
  extCardType
FROM all_pokemon_data
WHERE 
  -- filtering for the Elite Trainer Boxes and related items. Since evolving skies has 4 total boxes, I added extra keywords to ensure they all display.
  (
    REGEXP_CONTAINS(LOWER(TRIM(name)), 'elite trainer box$|pokemon center elite trainer box \\(exclusive\\)$|evolving skies elite trainer box|evolving skies pokemon center elite trainer box')
    AND NOT REGEXP_CONTAINS(LOWER(TRIM(name)), 'code card|case|set of')
  )

UNION ALL

SELECT
  set_name,
  name,
  avgPrice,
  marketPrice,
  extCardType
FROM ranked_cards
WHERE
  -- filters for the top 10 most expensive cards in each set.
  card_ranking <= 10
ORDER BY 
  set_name,
  marketPrice DESC;