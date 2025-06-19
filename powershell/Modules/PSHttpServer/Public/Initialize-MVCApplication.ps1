function Initialize-MVCApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )
    
    begin {
        $fullPath = (Resolve-Path $Path -ErrorAction SilentlyContinue).Path
        
        if (-not $fullPath) {
            $fullPath = (New-Item -Path $Path -ItemType Directory -Force).FullName
        }
        elseif ((Get-ChildItem -Path $fullPath -Force) -and -not $Force) {
            throw "Directory is not empty. Use -Force to overwrite existing files."
        }
    }
    
    process {
        # Create MVC directory structure
        $directories = @(
            "Controllers",
            "Models",
            "Views",
            "Views\Home",
            "Views\Shared",
            "wwwroot",
            "wwwroot\css",
            "wwwroot\js",
            "wwwroot\images"
        )
        
        foreach ($dir in $directories) {
            $dirPath = Join-Path -Path $fullPath -ChildPath $dir
            if (-not (Test-Path -Path $dirPath)) {
                New-Item -Path $dirPath -ItemType Directory -Force | Out-Null
                Write-Host "Created directory: $dirPath" -ForegroundColor Green
            }
        }
        
        # Create sample files
        
        # 1. Create default layout
        $layoutPath = Join-Path -Path $fullPath -ChildPath "Views\Shared\_Layout.html"
        $layoutContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{PageTitle}} - PSHttpServer App</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="/">Home</a></li>
                <li><a href="/about">About</a></li>
                <li><a href="/contact">Contact</a></li>
            </ul>
        </nav>
    </header>
    
    <main>
        {{Content}}
    </main>
    
    <footer>
        <p>&copy; 2025 - PSHttpServer Application</p>
    </footer>
    
    <script src="/js/main.js"></script>
</body>
</html>
"@
        Set-Content -Path $layoutPath -Value $layoutContent
        
        # 2. Create CSS file
        $cssPath = Join-Path -Path $fullPath -ChildPath "wwwroot\css\styles.css"
        $cssContent = @"
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 0;
    color: #333;
}

header {
    background-color: #4a5568;
    color: white;
    padding: 1rem;
}

nav ul {
    display: flex;
    list-style: none;
    padding: 0;
}

nav ul li {
    margin-right: 1rem;
}

nav ul li a {
    color: white;
    text-decoration: none;
}

main {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
}

footer {
    background-color: #f7fafc;
    padding: 1rem;
    text-align: center;
    border-top: 1px solid #e2e8f0;
}
"@
        Set-Content -Path $cssPath -Value $cssContent
        
        # 3. Create JS file
        $jsPath = Join-Path -Path $fullPath -ChildPath "wwwroot\js\main.js"
        $jsContent = @"
// Main JavaScript file for the application
document.addEventListener('DOMContentLoaded', function() {
    console.log('PSHttpServer application loaded');
});
"@
        Set-Content -Path $jsPath -Value $jsContent
        
        # 4. Create HomeController
        $controllerPath = Join-Path -Path $fullPath -ChildPath "Controllers\HomeController.ps1"
        $controllerContent = @"
# HomeController.ps1
# Contains route handlers for home-related pages

function Get-Index {
    param (
        [Parameter(Mandatory=`$true)]
        [System.Net.HttpListenerRequest]`$Request,
        
        [Parameter(Mandatory=`$true)]
        [System.Net.HttpListenerResponse]`$Response
    )
    
    # Get the view content
    `$viewPath = Join-Path -Path `$script:ViewsPath -ChildPath "Home\Index.html"
    `$viewContent = Get-Content -Path `$viewPath -Raw
    
    # Get the layout
    `$layoutPath = Join-Path -Path `$script:ViewsPath -ChildPath "Shared\_Layout.html"
    `$layoutContent = Get-Content -Path `$layoutPath -Raw
    
    # Replace placeholders in the view
    `$viewContent = `$viewContent -replace '{{Message}}', 'Welcome to PSHttpServer!'
    
    # Insert view into layout
    `$pageContent = `$layoutContent -replace '{{Content}}', `$viewContent -replace '{{PageTitle}}', 'Home'
    
    # Set response properties
    `$Response.ContentType = "text/html"
    
    return `$pageContent
}

function Get-About {
    param (
        [Parameter(Mandatory=`$true)]
        [System.Net.HttpListenerRequest]`$Request,
        
        [Parameter(Mandatory=`$true)]
        [System.Net.HttpListenerResponse]`$Response
    )
    
    # Get the view content
    `$viewPath = Join-Path -Path `$script:ViewsPath -ChildPath "Home\About.html"
    `$viewContent = Get-Content -Path `$viewPath -Raw
    
    # Get the layout
    `$layoutPath = Join-Path -Path `$script:ViewsPath -ChildPath "Shared\_Layout.html"
    `$layoutContent = Get-Content -Path `$layoutPath -Raw
    
    # Insert view into layout
    `$pageContent = `$layoutContent -replace '{{Content}}', `$viewContent -replace '{{PageTitle}}', 'About'
    
    # Set response properties
    `$Response.ContentType = "text/html"
    
    return `$pageContent
}

function Get-Contact {
    param (
        [Parameter(Mandatory=`$true)]
        [System.Net.HttpListenerRequest]`$Request,
        
        [Parameter(Mandatory=`$true)]
        [System.Net.HttpListenerResponse]`$Response
    )
    
    # Get the view content
    `$viewPath = Join-Path -Path `$script:ViewsPath -ChildPath "Home\Contact.html"
    `$viewContent = Get-Content -Path `$viewPath -Raw
    
    # Get the layout
    `$layoutPath = Join-Path -Path `$script:ViewsPath -ChildPath "Shared\_Layout.html"
    `$layoutContent = Get-Content -Path `$layoutPath -Raw
    
    # Insert view into layout
    `$pageContent = `$layoutContent -replace '{{Content}}', `$viewContent -replace '{{PageTitle}}', 'Contact'
    
    # Set response properties
    `$Response.ContentType = "text/html"
    
    return `$pageContent
}
"@
        Set-Content -Path $controllerPath -Value $controllerContent
        
        # 5. Create Views
        $indexViewPath = Join-Path -Path $fullPath -ChildPath "Views\Home\Index.html"
        $indexViewContent = @"
<div class="home-page">
    <h1>Welcome to PSHttpServer</h1>
    <p>{{Message}}</p>
    <p>This is a sample application built with PowerShell using MVC pattern.</p>
</div>
"@
        Set-Content -Path $indexViewPath -Value $indexViewContent
        
        $aboutViewPath = Join-Path -Path $fullPath -ChildPath "Views\Home\About.html"
        $aboutViewContent = @"
<div class="about-page">
    <h1>About PSHttpServer</h1>
    <p>PSHttpServer is a PowerShell module that provides an MVC framework for building web applications.</p>
    <p>Built with PowerShell and System.Net.HttpListener, it allows you to create web applications
       using the Model-View-Controller pattern without needing IIS or other external web servers.</p>
</div>
"@
        Set-Content -Path $aboutViewPath -Value $aboutViewContent
        
        $contactViewPath = Join-Path -Path $fullPath -ChildPath "Views\Home\Contact.html"
        $contactViewContent = @"
<div class="contact-page">
    <h1>Contact Us</h1>
    <p>Have questions or suggestions? Feel free to contact us.</p>
    <form>
        <div>
            <label for="name">Name:</label>
            <input type="text" id="name" name="name">
        </div>
        <div>
            <label for="email">Email:</label>
            <input type="email" id="email" name="email">
        </div>
        <div>
            <label for="message">Message:</label>
            <textarea id="message" name="message" rows="4"></textarea>
        </div>
        <button type="submit">Send</button>
    </form>
</div>
"@
        Set-Content -Path $contactViewPath -Value $contactViewContent
        
        Write-Host "MVC application initialized at: $fullPath" -ForegroundColor Green
        Write-Host "To start the web server:" -ForegroundColor Cyan
        Write-Host "Import-Module PSHttpServer" -ForegroundColor White
        Write-Host "Start-WebServer -AppPath '$fullPath'" -ForegroundColor White
    }
}
