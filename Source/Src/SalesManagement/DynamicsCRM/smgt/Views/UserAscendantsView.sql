CREATE VIEW [Smgt].[UserAscendantsView]
	AS 

WITH myCTE(systemuserid, emailaddress, ascendantsystemuserid, ascendantemailaddress, EmployeeLevel) AS
(
-- Anchor
SELECT u.systemuserid, u.internalemailaddress, u.systemuserid as ascendantsystemuserid, u.internalemailaddress as ascendantemailaddress, 0 
FROM [systemuser] u WHERE internalemailaddress is not null and SCRIBE_DELETEDON is null and isdisabled=0

UNION ALL

-- ...and the recursive part
SELECT c.systemuserid, c.emailaddress, u.parentsystemuserid AS ascendantsystemuserid, (SELECT internalemailaddress FROM systemuser WHERE u.parentsystemuserid=systemuserid) AS ascendantemailaddress, EmployeeLevel+1
FROM myCTE c
JOIN [systemuser] u
ON c.ascendantsystemuserid = u.systemuserid
where u.parentsystemuserid IS NOT NULL AND u.SCRIBE_DELETEDON IS NULL AND u.isdisabled=0
)

select myCTE.systemuserid [User Id], myCTE.emailaddress [Email], myCTE.ascendantsystemuserid [Ascendant User Id], myCTE.ascendantemailaddress [Ascendant Email], myCTE.EmployeeLevel [Employee Level], um.DomainUser [Ascendant Domain User]
FROM myCTE 
LEFT OUTER JOIN smgt.userMapping um
ON myCTE.ascendantsystemuserid = um.UserId

