PART-A: The Zoom Meeting and Query
---------------------------------------------------
On my earlier discussion and the zoom meeting with your team, I just made the meeting short,
only because of two questions. I asked the person, who had a fresh setup of your server a few days earlier the following questions:
Question 01- Which webserver is loading the application?
Question 02- Whether he is familiar with the term Kestrel?

When I found his lacking in those two terms, I didn't want to continue my further discussion, rather concentrate on the problem you are currently having.
I also had a query on two basic variables:
(a) Http Service Request Queues\MaxQueueItemAge
(b) Http Service Request Queues\ArrivalRate
Which are basically the Kestrel server (the default server for your application) configuration
and can be found under Kestrel configuration from an appsettings.json or appsettings.{Environment}.json file:
{ "Kestrel": { "Limits": { "MaxConcurrentConnections": 100, "MaxConcurrentUpgradedConnections": 100 }, "DisableStringReuse": true }}

PART-B: Basic Information I have received about your server and ASP.NET version
---------------------------------------------------------------------------------------------------------------
The basic information that I have received as below:
(a) Windows Server: IIS -8.5, is far old as IIS 10.0.1776331 is the latest version
(b) Application on- ASP.NET - 4.5, also an old one, latest is 4.8
(c) Problem Type: System often slows down, periodically hangs, takes time to dispatch the webservice and db service request

PART-C:
------
To optimize your server setup and enhance the operational outflow, I would suggest the team to read the following two blogs found to be resourceful for me:
(a) Identify the type of problem you are facing:
https://www.leansentry.com/Guide/IIS-AspNet-Hangs
**** Note: Read it and follow the steps as suggested.

(b) Check your Kestrel default server setup and modify for best experience:
https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-3.1
Parameters to have a look:
--------------------------
> Keep-alive timeout
> Maximum client connections
> Maximum request body size
> Minimum request body data rate
> Request headers timeout
> Maximum streams per connection
> Header table size
> Maximum frame size
> Maximum request header size
> Initial connection window size
> Initial stream window size
> Synchronous I/O
> ListenOptions.UseHttps
> Connection logging
> Bind to a TCP socket   <---- My suggestion, dont use it , rather use unix sock binding as it is much faster is processing requests
> Bind to a Unix socket <--- Recommended

Check out the following configurations:
---------------------------------------
> Endpoint configuration
> ConfigureEndpointDefaults(Action<ListenOptions>)
> ConfigureHttpsDefaults(Action<HttpsConnectionAdapterOptions>)
> Configure(IConfiguration)
> IIS endpoint configuration  <-- its better for a professional level software to have Http2 (checkout serverOptions.Configure)
> Transport configuration
> Host filtering

*** Check out all those and design a script for the health monitoring of your system as you are currently missing a standard core server system setup and
the absence of CI/CD pipeline will also slowdown your system in near future.


My Recommendation
------------------
Technical Recommendation
===========================
(1) Reverse Proxy: The professional level ASP.NET software requires not only to relay around its default Kestrel server, rather a reverse proxy implementation either with
Apache 2.4.43/Nginx 1.17/IIS. The reverse proxy will easy you application request handling and data processing
Check out the links for full understanding:
https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/?view=aspnetcore-3.1&tabs=linux
https://stackoverflow.com/questions/39248345/weblistener-vs-kestrel-why-choose-one-over-the-other-pros-cons

(2) Distributed Caching Engine and Full Page Cache: I think, the current servers of EduSoft has no considerations of distributed Cache Service like REDIS (master-slave architecture)  and
Full Page cache service like Varnish.
(3) OpCache like PHP is not required: I would recommend for OpCache to check your cache health, but that's not required for ASP.NET as the output DLL is already compiled.
(4) Alternative of Kestrel: If you are having trouble on Kestrel server, then you can use an alternative of it, HTTP.sys.
(5) Load Balancer automation: I would further request you to configure your ASP.NET Core to work with the proxy servers and load balancers only if you had the reverse proxy is in place
read: https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-3.1
(6) What about the rabbitmq? --> Advanced Message Queuing Protocol and has since been extended with a plug-in architecture to support
Streaming Text Oriented Messaging Protocol, MQ Telemetry Transport, and other protocols
(7) Where is your real time monitoring of the several logs to identify the core server and application issues:
Do you have any plan to use ELK (Elastic Search, LogStash, Kibana) stack.


Strategic Recommendation
========================
(a) As your company is serving around 17+ educational institution, with current automation and configuration the problem will raise
as the application is having more modules and consumers.
(b) Its better if you have a full time DevOps engineer or if not, then have a DevOps consultant who has the understanding and implementation capabilites
of the latest technologies like
> ASP.NET 2.x core
> HTTP.sys
> Distributed Redis Architecture
> Proxy and reverse proxy using Apache, Nginx
> Full page cache service like Varnish
> Advanced message Queuing protocol- Rabbitmq
>  Amazon Web Service (Ec2, load balancer, Security Group, SES,SNS,CloudWatch, CloudTrail, VPC etc, route 53 etc)
>  ELK setup

Business Strategic Recommendation
---------------------------------
> if you want your server operaitonal cost to be optimized, then better to go for
a ComputeOptimized AWS EC2 with Centos 7 and further virtualization into it with OpenVZ so that from a single server without hindering the operations,
you can create n number of containers, where each container will serve as a dedicated server for your application for different educational institutions.
> Separate your application server from webserver to further standarize your application processing.
> Go for a opensource Ticketing system as I earlier discussed for easy consumer management or a CRM (Customer Relationship Management) solution
and tracking your developers activities along with Toggle and BaseCamp.
> and ofcourse use slack for office communication.

Fast Solution:
--------------
As you are having the problem at current time and wants to solve it asap without alter much your current configuration, plz go through PART-C.
This may give your a PATCH solution, but will not last long, until you have a sophisticated server design and CI/CD pipeline.



Resources:
Reverse Proxy Design
(a) https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/?view=aspnetcore-3.1&tabs=linux
(b) https://stackoverflow.com/questions/39248345/weblistener-vs-kestrel-why-choose-one-over-the-other-pros-cons

Problem Discussion
(c) https://www.leansentry.com/Guide/IIS-AspNet-Hangs
(d) https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-3.1
(e) https://github.com/dotnet/aspnetcore/issues/17814

No Opcache required
(f) https://github.com/dotnet/aspnetcore/issues/17814

ASP.NET with proxy and load balancer
(g) https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-3.1

ASP.NET in Centos 7
(h) https://www.vultr.com/docs/how-to-deploy-a-net-core-web-application-on-centos-7
