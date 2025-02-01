///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область СлужебныйПрограммныйИнтерфейс

Функция КартинкаПоИмени(ИмяКартинки) Экспорт
	
	Возврат БиблиотекаКартинок[ИмяКартинки];	
	
КонецФункции   

Функция МетаданныеПеречислений() Экспорт 
	
	МассивТипов = Новый Массив;
	
	Для Каждого МетаданныеПеречисления Из Метаданные.Перечисления Цикл
		МассивТипов.Добавить(МетаданныеПеречисления);
	КонецЦикла;   
	
	Возврат Новый ФиксированныйМассив(МассивТипов);
	
КонецФункции

#КонецОбласти