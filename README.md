regexp("LogFileUsage:(\d+(\.\d+)?)", {<Your_Hostname>:db2.metrics[LogFileUsage].last()})

regexp("LogFileUsage:(\d+(.\d+)?)", {ASOMDWFDB404:db2.metrics[LogFileUsage].last()})

Invalid parameter "/1/params": incorrect calculated item formula starting from ")})". [items.php:686 → CApiWrapper->__call() → CFrontendApiWrapper->callMethod() → CApiWrapper->callMethod() → CFrontendApiWrapper->callClientMethod() → CLocalApiClient->callMethod() → CItem->create() → CItemGeneral->checkInput() → CApiService::exception() in include/classes/api/services/CItemGeneral.php:331]
