-- Create a list of all ascendants of each user in the org and an individual is considered his or her own ascendant.
CREATE view [Smgt].[UserAscendantsView] as

WITH myCTE(userid, emailaddress, ascendantuserid, ascendantemailaddress, EmployeeLevel) AS
(
-- Anchor
SELECT u.id as userid, u.email, u.id as ascendantuserid, u.email as ascendantemailaddress, 0 
FROM [user] u WHERE email IS NOT NULL AND isactive=1

UNION ALL

-- ...and the recursive part
SELECT c.userid, c.emailaddress, u.managerid AS ascendantuserid, (SELECT email FROM [user] WHERE u.managerid=id) AS ascendantemail, EmployeeLevel+1
FROM myCTE c
JOIN [user] u
ON c.ascendantuserid = u.id
where u.managerid IS NOT NULL AND u.isactive=1
)

select myCTE.userid [User Id], myCTE.emailaddress [Email], myCTE.ascendantuserid [Ascendant User Id], myCTE.ascendantemailaddress [Ascendant Email], myCTE.EmployeeLevel [Employee Level], um.DomainUser [Ascendant Domain User]
FROM myCTE 
LEFT OUTER JOIN smgt.userMapping um
ON myCTE.ascendantuserid = um.OwnerId