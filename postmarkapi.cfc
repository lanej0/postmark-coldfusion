<cfcomponent name="PostMarkAPI" hint="I send messages using the Postmarkapp.com API">
	<cffunction name="sendMail" access="public" returntype="string" description="Assembles JSON packet and sends it to Postmarkapp">
		<!--- Recipient and subject are required parameters.  Also need their API key. --->
		<cfargument name="mailTo" required="yes" type="string" displayname="Recipient of the message" />
		<cfargument name="mailFrom" required="yes" type="string" displayname="Sender of the message" />
		<cfargument name="mailSubject" required="yes" type="string" displayname="Subject of the message" />
		<cfargument name="apiKey" required="yes" type="string" displayname="API key, or server token">
		<!--- CC recipients, tag, text body and HTML body are all optional --->
		<cfargument name="mailReply" required="no" type="string" displayname="Reply-to Address (if applicable)" />
		<cfargument name="mailCc" required="no" type="string" displayname="CC recipients (if applicable)" />
		<cfargument name="mailBcc" required="no" type="string" displayname="BCC recipients (if applicable)" />
		<cfargument name="mailHTML" required="no" type="string" displayname="HTML body of the message" />
		<cfargument name="mailTxt" required="no" type="string" displayname="Plain text body of the message" />
		<cfargument name="mailTag" required="no" type="string" displayname="Tag for message" />
		<!---Need to escape strings for JSON --->
		<cfset mailto = #JSStringFormat(arguments.mailTo)# />
		<cfset mailFrom = #JSStringFormat(arguments.mailFrom)#>
		<cfset mailSubject = #JSStringFormat(arguments.mailSubject)# />
		<cfif IsDefined("arguments.mailCc") AND #arguments.mailCc# NEQ "">
			<cfset mailCc = #JSStringFormat(arguments.mailCc)# />
		</cfif>
		<cfif IsDefined("arguments.mailBcc") AND #arguments.mailBcc# NEQ "">
			<cfset mailBcc = #JSStringFormat(arguments.mailBcc)# />
		</cfif>
		<cfif IsDefined("arguments.mailHTML") AND #arguments.mailHTML# NEQ "">
			<cfset mailHTML = #JSStringFormat(arguments.mailHTML)# />
		</cfif>
		<cfif IsDefined("arguments.mailTxt") AND #arguments.mailTxt# NEQ "">
			<cfset mailTxt = #JSStringFormat(arguments.mailTxt)# />
		</cfif>
		<cfif IsDefined("arguments.mailReply") AND #arguments.mailReply# NEQ "">
			<cfset mailReply = #JSStringFormat(arguments.mailReply)# />
		</cfif>
		<cfif IsDefined("arguments.mailTag") AND #arguments.mailTag# NEQ "">
			<cfset mailTag = #JSStringFormat(arguments.mailTag)# />
		</cfif>
		<!--- Assemble the JSON packet to send to Postmarkapp --->
		<cfsavecontent variable="jsonPacket">
			<cfprocessingdirective suppressWhiteSpace="yes">
				<cfoutput>
				{
					"From" : "#mailFrom#", 
					"To" : "#mailTo#", 
					<cfif IsDefined("mailCc")>"Cc" : "#mailCc#",</cfif> 
					<cfif IsDefined("mailBcc")>"Bcc" : "#mailBcc#",</cfif>
					"Subject" : "#mailSubject#" 
					<cfif IsDefined("mailHTML")>, "HTMLBody" : "#mailHTML#"</cfif>
					<cfif IsDefined("mailTxt")>, "TextBody" : "#mailTxt#"</cfif>
					<cfif IsDefined("mailReply")>, "ReplyTo" : "#mailReply#"</cfif>
					<cfif IsDefined("mailTag")>, "Tag" : "#mailTag#"</cfif>
				}
				</cfoutput>
			</cfprocessingdirective>	
		</cfsavecontent>
		<!--- Send the request to Postmarkapp --->
		<cfhttp url="http://api.postmarkapp.com/email" method="post">
			<cfhttpparam type="header" name="Accept" value="application/json" />
			<cfhttpparam type="header" name="Content-type" value="application/json" />
			<cfhttpparam type="header" name="X-Postmark-Server-Token" value="#arguments.apiKey#" />
			<cfhttpparam type="body" encoded="no" value="#jsonPacket#" />
		</cfhttp>
		<!--- Return the status code --->
		<cfset pmCode = #cfhttp.statusCode# />
		<cfreturn pmCode />
	</cffunction>
</cfcomponent>