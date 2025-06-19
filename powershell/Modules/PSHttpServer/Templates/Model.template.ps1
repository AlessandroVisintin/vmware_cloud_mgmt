class {{ModelName}} {
{{Properties}}
    
    # Constructor
    {{ModelName}}() {
        # Default constructor
    }
    
    # You can add additional methods here
    [string] ToString() {
        return "{{ModelName}} Instance"
    }
}

# Function to create a new instance of this model
function New-{{ModelName}} {
    param (
        # Add parameters for properties here
    )
    
    $model = [{{ModelName}}]::new()
    
    # Set properties based on parameters
    # $model.Property = $Value
    
    return $model
}
    