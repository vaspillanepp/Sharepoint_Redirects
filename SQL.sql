-- SQLite
SELECT servername, F5Addr, Location, Servers
FROM servers;

select * from urls;

select servers from urls;
select servername, servers from servers;

Select urls.location, servers.location,
urls.servers, servers.servers,
urls.URL,servers.servername from urls
inner join servers 
on urls.Location = servers.Location
   and urls.servers = servers.servers;


--CREATE [TEMP] VIEW [IF NOT EXISTS] view_name[(column-name-list)]
--AS 
--   select-statement;

--CREATE VIEW IF NOT EXISTS urlservers
CREATE VIEW urlservers
AS 
   SELECT urls.*,servers.servername, 
   CASE WHEN urls.location is 'PITC' THEN servers.servername || ".aac.dva.va.gov" 
    ELSE servers.servername || ".vba.va.gov" END AS fqdn
   FROM urls
    INNER JOIN servers 
    ON urls.Location = servers.Location
        AND urls.servers = servers.servers;

drop view urlservers


SELECT urls.location, servers.location,
urls.servers, servers.servers,
urls.URL,servers.servername,
CASE WHEN urls.location is 'PITC' THEN servers.servername || ".aac.dva.va.gov" 
    ELSE servers.servername || ".vba.va.gov" END AS fqdn
FROM urls
inner join servers 
on urls.Location = servers.Location
   and urls.servers = servers.servers;


SELECT location,servers,location,env,fqdn,servername,listenport,url
FROM urlservers;

select * from urlservers;

select servers,env,location,StartStopService,url,wl12,wl12ssl,fqdn,ListenPort,servername from urlservers;


select servers,env,location,StartStopService,url,wl12,wl12ssl,fqdn,ListenPort,servername 
            from urlservers

select DISTINCT servers,env,location,StartStopService,url,wl12,wl12ssl,ListenPort 
            from urlservers
            where url = "bepdev.vba.va.gov"

select DISTINCT env,location,StartStopService,url,wl12,wl12ssl,ListenPort from urlservers
         