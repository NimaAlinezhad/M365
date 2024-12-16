Add-Type -AssemblyName PresentationFramework

function Generate-FlexibleRegEx {
    param (
        [Parameter(Mandatory)]
        [string]$InputPattern,
        [Parameter(Mandatory)]
        [bool]$IncludeSpaces
    )

    # Base RegEx without spaces
    $baseRegex = ""
    $flexibleRegex = ""

    for ($i = 0; $i -lt $InputPattern.Length; $i++) {
        $char = $InputPattern[$i]

        if ($char -match "\d") {
            # Match digits (\d)
            $baseRegex += "\d"
            $flexibleRegex += "\d\s?"
        } elseif ($char -match "[A-Za-z]") {
            # Match letters ([A-Za-z])
            $baseRegex += "[A-Za-z]"
            $flexibleRegex += "[A-Za-z]"
        } elseif ($char -match "\s") {
            # Skip spaces for the base version but allow optional spaces for flexible version
            continue
        } else {
            # Match other characters literally
            $baseRegex += "\Q$char\E"
            $flexibleRegex += "\Q$char\E"
        }
    }

    # Cleanup trailing optional spaces in the flexible version
    $flexibleRegex = $flexibleRegex -replace "\s\?$", ""

    # Combine results based on IncludeSpaces flag
    if ($IncludeSpaces) {
        return "\b$flexibleRegex\b|\b$baseRegex\b"
    } else {
        return "\b$baseRegex\b"
    }
}

function Show-GUI {
    # Create the window
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Flexible RegEx Generator"
    $form.Size = New-Object System.Drawing.Size(500, 400)
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
    $outputBox.Size = New-Object System.Drawing.Size(450, 50)
    $outputBox.Multiline = $true
    $outputBox.ReadOnly = $true
    $outputBox.Location = New-Object System.Drawing.Point(10, 180)
    $form.Controls.Add($outputBox)

    # Button click event
    $generateButton.Add_Click({
        $input = $inputBox.Text
        $includeSpaces = $checkbox.Checked

        if ([string]::IsNullOrWhiteSpace($input)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter an ID or number!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } else {
            $regex = Generate-FlexibleRegEx -InputPattern $input -IncludeSpaces $includeSpaces
            $outputBox.Text = $regex
        }
    })

    # Show the window
    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()
}

# Start the GUI
Show-GUI
