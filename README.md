
To extract only the numeric values for both `DBSize` and `LogFileUsage` using Zabbix preprocessing regular expressions, you can set up two preprocessing rules, one for each field. Here's how you can do it:

1. **Navigate to the item**: Go to the Zabbix web interface and locate the item where you want to apply preprocessing.

2. **Edit the item**: Click on the item.

3. **Go to preprocessing**: Navigate to the "Preprocessing" tab.

4. **Create preprocessing rule for DBSize**:
   - Choose preprocessing type: Select "Regular expression" from the dropdown menu.
   - Regular expression for DBSize: `DBSize:(\d+)`
   - Output: Leave the "Output" field empty.
   - Data type: Choose "Numeric (unsigned)" or "Numeric (float)" based on the type of value expected for DBSize.
   - Save the preprocessing rule.

5. **Create preprocessing rule for LogFileUsage**:
   - Choose preprocessing type: Select "Regular expression" from the dropdown menu.
   - Regular expression for LogFileUsage: `LogFileUsage:(\d+(\.\d+)?)`
   - Output: Leave the "Output" field empty.
   - Data type: Choose "Numeric (float)" as the data type.
   - Save the preprocessing rule.

With these preprocessing rules, Zabbix will extract the numeric values associated with both `DBSize` and `LogFileUsage` from the item output and store them as separate numeric items. You can then use these items for triggers, graphs, or other monitoring purposes.

