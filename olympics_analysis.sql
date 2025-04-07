--Identify the sport which was played in all summer Olympic games--

with t1 as
(Select Count(distinct games) as total_summer_games
	 From Olympics_History
     Where Season = 'Summer'
     Order by Games),
     
 #Total is 29
  
 t2 as
	(Select Distinct sport, games
    From Olympics_History
    Where Season = 'Summer' 
    Order by Games
    ),

t3 as
(Select sport, Count(games) as no_of_games
From t2
Group by sport)
    
    Select *
    From t3
	
join t1 on t1.total_summer_games = t3.no_of_games;


#Fetch the top 5 athletes who have won the most gold medals
with t1 as
(Select Name, Sex, Age, Team, count(*) as total_medals
From Olympics_History
Where medal =  'Gold'
Group by Name, Sex, Age, Team
Order by total_medals DESC
),

t2 as 
(Select *, dense_rank() over(Order by total_medals) as Rnk
From t1)
Select * 
From t2
Where Rnk <= 5 ;

-- List total gold, silver and bronze medals won by each county --

#Below shows in a row level - need to get medal types in column level
Select nr.region as country, medal, count(medal) total_medal
From Olympics_History as oh
Join Olympics_History_Noc_Regions as nr on nr.noc = oh.noc
Where medal <> 'NA'
Group by nr.region, medal
Order by nr.region, medal;

Select nr.region as country,
Sum(Case When Medal = 'Gold' Then 1 Else 0 End) AS 'Gold',
Sum(Case When Medal = 'Silver' Then 1 Else 0 End) AS 'Silver',
Sum(Case When Medal = 'Bronze' Then 1 Else 0 End) AS 'Bronze'
FROM Olympics_History oh
Join Olympics_History_Noc_Regions as nr on nr.noc = oh.noc
Where Medal in ('Gold', 'Silver', 'Bronze')
Group by nr.region, medal
Order by Gold Desc, Silver Desc, Bronze Desc;

-- Which county won the most gold, silver and bronze in each olympic games --

WITH medal_counts AS (
  SELECT games,team,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold_count,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver_count,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_count
  FROM Olympics_History
  WHERE Medal in ('Gold', 'Silver', 'Bronze')
  GROUP BY Games, Team
),

ranked_medals AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY Games ORDER BY gold_count DESC) AS gold_rank,
    ROW_NUMBER() OVER (PARTITION BY Games ORDER BY silver_count DESC) AS silver_rank,
    ROW_NUMBER() OVER (PARTITION BY Games ORDER BY bronze_count DESC) AS bronze_rank
  FROM medal_counts
)

SELECT
  Games,
  CONCAT(MAX(CASE WHEN gold_rank = 1 THEN Team END), ' - ', MAX(CASE WHEN gold_rank = 1 THEN gold_count END)) AS max_gold,
  CONCAT(MAX(CASE WHEN silver_rank = 1 THEN Team END), ' - ', MAX(CASE WHEN silver_rank = 1 THEN silver_count END)) AS max_silver,
  CONCAT(MAX(CASE WHEN bronze_rank = 1 THEN Team END), ' - ', MAX(CASE WHEN bronze_rank = 1 THEN bronze_count END)) AS max_bronze
FROM ranked_medals
GROUP BY Games
ORDER BY Games;

