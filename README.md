Thank you for the clarification. If you're extracting a numeric value using a regular expression in Zabbix preprocessing, and the data type of the item is expected to be numeric (floating point), you need to ensure that the output of the preprocessing rule is also of the correct data type.

Here's how you can set it up correctly:

1. **Navigate to the item**: Go to the Zabbix web interface and locate the item where you want to apply preprocessing.

2. **Edit the item**: Click on the item.

3. **Go to preprocessing**: Navigate to the "Preprocessing" tab.

4. **Create preprocessing rule**: Click on the "Create Preprocessing" button.

5. **Choose preprocessing type**: Select "Regular expression" from the dropdown menu.

6. **Set up the regular expression**: In the "Regular expression" field, enter the regular expression to extract the numeric value. For example, if the numeric value is preceded by "DBSize:", you can use the regular expression `DBSize:(\d+(\.\d+)?)`.

7. **Provide the extracted value as the "Output"**: Since you're extracting a numeric value, provide the extracted value itself as the output. You don't need to perform any replacements. So, in the "Output" field, enter `{1}` to refer to the first capture group in the regular expression.

8. **Set the appropriate data type for the output**: Choose "Numeric (float)" as the data type for the output.

9. **Save the preprocessing rule**: Once you're satisfied with the configuration, click "Add" or "Save" to create the preprocessing rule.

With this setup, Zabbix will extract the numeric value using the specified regular expression and store it as a floating-point number without performing any replacements. The placeholder `{1}` in the "Output" field refers to the first capture group in the regular expression, which contains the numeric value.