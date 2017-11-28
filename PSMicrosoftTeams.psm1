﻿<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.140
	 Created on:   	22/11/2017 12:36 PM
	 Created by:   	Matthewh Houston	
	 Organization: 	
	 Filename:     	PSMicrosoftTeams.psm1
	-------------------------------------------------------------------------
	 Module Name: PSMicrosoftTeams
	===========================================================================
	.Synopsis
	Send a message to Micrsoft Teams.

	.Description
	Send a message to a Microsoft Teams 'Webhook' URI. This can include a title, description and details.

	.Parameter messageType
	The type of message to send, valid types are 'Information','Warning','Critical'. This will decide what icon to apply.

	.Parameter messageTitle
	The main message title, this heads up all the sections.

	.Parameter messageBody
	The main details of the message, this will contain a description of the information.

	.Parameter activityTitle
	A sub-heading for sectioning off the message into parts. Currently implemented to separate the 'details' section.

	.Parameter details
	An array of hashtables to display key pairs of names and values. Use this to display specific technical information if required.

	.Parameter URI
	The full URI provided when a webhook is created for an MS Teams channel

	.Example
	# Display a critical message, URI has been obfuscated
	Send-TeamChannelMessage -messageType Information -messageTitle "Test Title" -messageBody "Test body" -activityTitle "test Activity" -URI "https://outlook.office.com/webhook/XXXX/IncomingWebhook/XXXX/XXXXXXx" -details @(@{ name = 'name1'; value = 'value1' }, @{ name = 'name2'; value = 'value2' }, @{ name = 'name3'; value = 'value3' })

#>

function Send-TeamChannelMessage
{
	Param (
		[Parameter(Mandatory = $true)]
		[ValidateSet("Information", "Warning", "Critical")]
		[string]$messageType,
		[Parameter(Mandatory = $true)]
		[string]$messageTitle,
		[Parameter(Mandatory = $true)]
		[string]$messageBody,
		[string]$activityTitle,
		[array]$details = $null,
		[array]$buttons = $null,
		[Parameter(Mandatory = $true)]
		[string]$URI
	)
	
	Switch ($messageType)
	{
		{ $_ -eq "Information" } { $notify = $true; $titleColor = "green"; $imageLink = "http://icons.iconarchive.com/icons/double-j-design/origami-colored-pencil/128/green-ok-icon.png" }
		{ $_ -eq "Warning" } { $notify = $true; $titleColor = "orange"; $imageLink = "http://icons.iconarchive.com/icons/double-j-design/origami-colored-pencil/256/yellow-cross-icon.png" }
		{ $_ -eq "Critical" } { $notify = $true; $titleColor = "red"; $imageLink = "http://icons.iconarchive.com/icons/double-j-design/origami-colored-pencil/128/red-cross-icon.png" }
	}
	
	$potentialActions = @()
	
	foreach ($button in $buttons)
	{
		$potentialActions += @{
			'@context' = 'http://schema.org'
			'@type'    = 'ViewAction'
			name	   = $($button.Name)
			target	 = @("$($button.Value)")
		}
	}
	
	$body = ConvertTo-Json -Depth 6 @{
		title    = "$($messageTitle)"
		text	 = "$($messageBody)"
		sections = @(
			@{
				activityTitle    = "$($activityTitle)"
				activitySubtitle = " "
				activityImage    = "$imageLink"
			},
			@{
				title = 'Details'
				facts = $details
				potentialAction = @(
					$potentialActions
				)
			}
		)
		
	}
	$body

	Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
}

Export-ModuleMember -Function *


