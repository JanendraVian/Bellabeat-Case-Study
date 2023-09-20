SELECT * FROM dailyActivity_merged$
SELECT * FROM sleepDay_merged$

-- Counting distinct Id count from each tables used.
SELECT COUNT(DISTINCT Id) FROM dailyActivity_merged$ --33
SELECT COUNT(DISTINCT Id) FROM sleepDay_merged$ --24


-- Converting Date to a better format in dailyActivity_merged$
ALTER TABLE dailyActivity_merged$
ADD NewActivityDate Date;
UPDATE dailyActivity_merged$
SET NewActivityDate = CONVERT(Date,ActivityDate)

-- Adding Day of the Week Name column in dailyActivity_merged$
ALTER TABLE dailyActivity_merged$
ADD DayWeek char(10);

UPDATE dailyActivity_merged$
SET DayWeek = DATENAME(dw, NewActivityDate)


-- Converting Date to a better format in sleepDay_merged$
ALTER TABLE sleepDay_merged$
ADD NewSleepDay Date;
UPDATE sleepDay_merged$
SET NewSleepDay = CONVERT(Date,SleepDay)

-- Adding Day of the Week Name column in sleepDay_merged$
ALTER TABLE sleepDay_merged$
ADD DayWeek char(10);

UPDATE sleepDay_merged$
SET DayWeek = DATENAME(dw, SleepDay)


-- Sum of activity leves for each (distinct) ids.
SELECT DISTINCT Id, 
SUM(SedentaryMinutes) as Sedentary,
SUM(LightlyActiveMinutes) as LightlyActive,
SUM(FairlyActiveMinutes) as FairlyActive, 
SUM(VeryActiveMinutes) as VeryActive
INTO NewSUMAct
FROM dailyActivity_merged$
GROUP BY Id

-- Combining dailyActivity_merged$ and sleepDay_merged$ into a new table
SELECT Activity.*, Sleep.TotalSleepRecords, Sleep.TotalMinutesAsleep, Sleep.TotalTimeInBed
INTO ActivitySleep
FROM dailyActivity_merged$ Activity
INNER JOIN sleepDay_merged$ Sleep 
ON Activity.Id = Sleep.Id AND Activity.NewActivityDate = Sleep.NewSleepDay

-- Adding Total Active Minutes column
SELECT *,
(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) TotalActiveMinutes,
(VeryActiveDistance+ModeratelyActiveDistance+LightActiveDistance) TotalActiveDistance
INTO CompleteData
FROM ActivitySleep

SELECT *,
(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) TrueTotalActiveMinutes,
(VeryActiveDistance+ModeratelyActiveDistance+LightActiveDistance) TrueTotalActiveDistance
INTO TrueDailyActivity
FROM dailyActivity_merged$
