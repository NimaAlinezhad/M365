#This PowerShell script provides a graphical user interface (GUI) for generating Regular Expressions (RegEx) based on user input.
#It is particularly useful for creating patterns to match IDs, numbers, or similar structured data.
#Users can enter a sample number or ID and optionally choose whether spaces within the input should be included in the generated RegEx.
#The generated RegEx is formatted to be compatible with Microsoft Purview Data Loss Prevention (DLP) policies and Sensitivity Info Types,
#making it an excellent tool for defining and customizing data patterns in compliance frameworks. For example, you can use this script to create RegEx patterns for matching custom IDs,
#IBANs, or other sensitive data formats used in your organization.
 
 
 Add-Type -AssemblyName PresentationFramework

function Generate-RegEx {
    param (
        [Parameter(Mandatory)]
        [string]$InputPattern,
        [Parameter(Mandatory)]
        [bool]$IncludeSpaces
    )

    # Initialize the RegEx
    $regex = ""

    # Iterate over each character in the input
    for ($i = 0; $i -lt $InputPattern.Length; $i++) {
        $char = $InputPattern[$i]
        
        if ($char -match "\d") {
            # Replace digits with \d
            if ($i -eq 0 -or $regex[-1] -ne "\d") {
                $regex += "\d"
            }
        } elseif ($char -match "[A-Za-z]") {
            # Replace letters with [A-Za-z]
            if ($i -eq 0 -or $regex[-1] -ne "[A-Za-z]") {
                $regex += "[A-Za-z]"
            }
        } elseif ($char -match "\s") {
            # Optional spaces as \s?
            if ($i -eq 0 -or $regex[-1] -ne "\s?") {
                $regex += "\s?"
            }
        } else {
            # Escape special characters
            $regex += "\Q$char\E"
        }
    }

    # Include spaces if the option is selected
    if ($IncludeSpaces) {
        $regex = $regex -replace "\d", "\d\s?"
        $regex = $regex -replace "\s\?$", ""
    }

    # Return the final RegEx
    return "\b$regex\b"
}

function Show-GUI {
    # Create the window
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "RegEx Generator"
    $form.Size = New-Object System.Drawing.Size(500, 350)
    $form.StartPosition = "CenterScreen"

    # Input field label
    $inputLabel = New-Object System.Windows.Forms.Label
    $inputLabel.Text = "Enter the ID or number:"
    $inputLabel.Size = New-Object System.Drawing.Size(400, 20)
    $inputLabel.Location = New-Object System.Drawing.Point(10, 10)
    $form.Controls.Add($inputLabel)

    # Input text box
    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Size = New-Object System.Drawing.Size(450, 20)
    $inputBox.Location = New-Object System.Drawing.Point(10, 40)
    $form.Controls.Add($inputBox)

    # Checkbox for spaces
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = "Include spaces"
    $checkbox.Size = New-Object System.Drawing.Size(200, 20)
    $checkbox.Location = New-Object System.Drawing.Point(10, 70)
    $form.Controls.Add($checkbox)

    # Generate button
    $generateButton = New-Object System.Windows.Forms.Button
    $generateButton.Text = "Generate RegEx"
    $generateButton.Size = New-Object System.Drawing.Size(150, 30)
    $generateButton.Location = New-Object System.Drawing.Point(10, 100)
    $form.Controls.Add($generateButton)

    # Output label
    $outputLabel = New-Object System.Windows.Forms.Label
    $outputLabel.Text = "Generated RegEx:"
    $outputLabel.Size = New-Object System.Drawing.Size(400, 20)
    $outputLabel.Location = New-Object System.Drawing.Point(10, 150)
    $form.Controls.Add($outputLabel)

    # Output text box
    $outputBox = New-Object System.Windows.Forms.TextBox
    $outputBox.Size = New-Object System.Drawing.Size(450, 20)
    $outputBox.Location = New-Object System.Drawing.Point(10, 180)
    $outputBox.ReadOnly = $true
    $form.Controls.Add($outputBox)

    # Button click event
    $generateButton.Add_Click({
        $input = $inputBox.Text
        $includeSpaces = $checkbox.Checked

        if ([string]::IsNullOrWhiteSpace($input)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter an ID or number!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } else {
            $regex = Generate-RegEx -InputPattern $input -IncludeSpaces $includeSpaces
            $outputBox.Text = $regex
        }
    })

    # Show the window
    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()
}

# Start the GUI
Show-GUI
