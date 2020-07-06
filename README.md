---


---

<h1 id="bat-center">BAT-Center</h1>
<p>BatCenter is a Win32 Commandline utility that allows you to download plugins from TheBATeam all from the windows command line interface.</p>
<h3 id="syntax-and-usage.">Syntax and Usage.</h3>
<p>The program must be present in the <mark><code>path</code></mark> environment or alternatively a cmd session should be started in a the working directory containing the BatCenter executable file.  <br></p>
<p><strong>Optional parameters :</strong></p>

<table>
<thead>
<tr>
<th><em>Parameter</em></th>
<th><em>Function</em></th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr>
<td>/<em>? or --? or -?</em></td>
<td>Print the help information to the standard output.</td>
<td><code>BatCenter.exe /?</code></td>
</tr>
<tr>
<td>-ver</td>
<td>Print the current/build version number to the standard output.</td>
<td><code>BatCenter.exe -ver</code></td>
</tr>
<tr>
<td><em>-update</em></td>
<td>Update from a specific GitHub user repository. The argument taken in this parameter is the “<strong>username</strong>”.</td>
<td><code>BatCenter.exe -update "KabueMurage"</code></td>
</tr>
<tr>
<td>-list</td>
<td>This parameter allows you to list out all the initialized repository names from the GitHub API. You may list the initialized repositories by using abbreviation:<br> <strong>P</strong>   -   For Project name.<br> <strong>des</strong> - For Project description.<br> <strong>url</strong> - For Project direct download links for the master branch. <br></td>
<td><code>BatCenter.exe -list p</code> <br> <code>BatCenter.exe -list des</code> <br> <code>BatCenter.exe -list url</code> <br> Using an unknown argument for this parameter will take the argument as a search string. <br> Example: <br> <code>BatCenter.exe -list "Http library"</code></td>
</tr>
<tr>
<td><em>-get</em></td>
<td>Downloads a repository to the working directory.</td>
<td><code>BatCenter.exe -get "Http library"</code> <br> This parameter can be used with <code>/unzip</code> to automatically download and unzip a repository within the working directory.</td>
</tr>
<tr>
<td>-unzip</td>
<td>Unzip a repository after downloading it. <br></td>
<td><code>BatCenter.exe -get "Http library" /unzip</code></td>
</tr>
<tr>
<td>-getdetail</td>
<td>Returns the information of a repository. The payload is in the format: <br> <strong>Name</strong> , <strong>description</strong>, <strong>forks count</strong>, <strong>download url</strong>, <strong>language</strong> , <strong>last commit date</strong>. <br>You can also get details using the nth index of a repository.</td>
<td><code>BatCenter.exe -getdetail 12</code> <br> <code>BatCenter.exe -getdetail "WinGet"</code></td>
</tr>
</tbody>
</table><h3 id="optional-flags.">Optional Flags.</h3>

<table>
<thead>
<tr>
<th><em>Flag</em></th>
<th><em>Function</em></th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr>
<td>/unzip</td>
<td>Set the unzipping action after the download function is called. By default, the downloaded archive is not extracted after downloading using <code>-get</code></td>
<td><code>BatCenter.exe -get "WinGet" /unzip</code></td>
</tr>
</tbody>
</table>
