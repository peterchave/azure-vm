<h2>Build an encoder on Azure via API</h2>

Uses newman to run postman collections to build VM on Azure, then remotely install an ffmpeg based encoder.
The ffmpeg encoder accepts an RTMP feed in then it publishes the output via Akamai MSL / AMD.

<h3>Setup</h3>
<ul>
<li>Install newman locally (https://www.npmjs.com/package/newman)</li>
<li>Clone the project locally</li>
<li>Modify azure-credentials.json with your Azure subscriptionID, tenantID, clientSecret, etc.</li>
</ul>
<h3>Build encoder (from scratch)</h3>
<code>./encoder-build.sh &lt;Name&gt; &lt;EPid&gt;</code><br>
<br>
&lt;Name&gt; - Identifier used for all created resources, must be unique and no contain spaces.<br>
&lt;EPid&gt; - The script requires an Akamai MSL entrypoint StreamID, just the number to set up ingest.<br>
<br>  
The script returns and RTMP entrypoint to send input stream to.
<h3>Build encoder (from image)</h3>
<code>./encoder-image.sh &lt;Name&gt; &lt;ImageName&gt; &lt;EPid&gt;</code><br>
<br>
&lt;ImageName&gt; - Name of image Ubuntu 18.04LTS with ffmpeg/nginx/pm2 installed on your Azure resource group.<br>
<br>
The script returns and RTMP entrypoint to send input stream to.
<h3>Start/restart encoder</h3>  
<code>./encoder-start.sh &lt;Name&gt;</code><br>
<h3>Delete encoder</h3>  
<code>./encoder-delete.sh &lt;Name&gt;</code>
