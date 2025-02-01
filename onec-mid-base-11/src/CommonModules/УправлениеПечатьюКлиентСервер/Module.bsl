///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область СлужебныйПрограммныйИнтерфейс

Функция ИмяТегаУсловие() Экспорт
	Возврат НСтр("ru = 'v8 Условие'");
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИменаПолейКоллекцииПечатныхФорм() Экспорт
	
	Поля = Новый Массив;
	Поля.Добавить("ИмяМакета");
	Поля.Добавить("ИмяВРЕГ");
	Поля.Добавить("СинонимМакета");
	Поля.Добавить("ТабличныйДокумент");
	Поля.Добавить("Экземпляров");
	Поля.Добавить("Картинка");
	Поля.Добавить("ПолныйПутьКМакету");
	Поля.Добавить("ИмяФайлаПечатнойФормы");
	Поля.Добавить("ОфисныеДокументы");
	Поля.Добавить("ДоступенВыводНаДругихЯзыках");
	Поля.Добавить("ТекстОшибкиФормирования");
	
	Возврат Поля;
	
КонецФункции

// См. УправлениеПечатью.НапечататьВФайл.
Функция НастройкиСохранения() Экспорт
	
	НастройкиСохранения = Новый Структура;
	НастройкиСохранения.Вставить("ФорматыСохранения", Новый Массив);
	НастройкиСохранения.Вставить("УпаковатьВАрхив", Ложь);
	НастройкиСохранения.Вставить("ПереводитьИменаФайловВТранслит", Ложь);
	НастройкиСохранения.Вставить("ПодписьИПечать", Ложь);
	
	Возврат НастройкиСохранения;
	
КонецФункции

Функция ИдентификаторОбласти(Область) Экспорт
	
	КоординатыОбласти = Новый Массив;
	КоординатыОбласти.Добавить(Формат(Область.Верх, "ЧГ=0"));
	КоординатыОбласти.Добавить(Формат(Область.Лево, "ЧГ=0"));
	КоординатыОбласти.Добавить(Формат(Область.Низ, "ЧГ=0"));
	КоординатыОбласти.Добавить(Формат(Область.Право, "ЧГ=0"));
	
	ИдентификаторОбласти = СтрСоединить(КоординатыОбласти, ":");
	
	Возврат ИдентификаторОбласти;
	
КонецФункции

#КонецОбласти
