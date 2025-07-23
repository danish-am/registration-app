FROM tomcat:latest

# Optional: Clean existing default apps if needed
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file from the Maven target directory
COPY webapp/target/*.war /usr/local/tomcat/webapps/ROOT.war
