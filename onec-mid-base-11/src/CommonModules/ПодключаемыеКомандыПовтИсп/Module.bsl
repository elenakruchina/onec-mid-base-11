///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область СлужебныеПроцедурыИФункции

Функция КэшФормы(Знач ИмяФормы, Знач ИсточникиЧерезЗапятую, Знач ЭтоФормаОбъекта) Экспорт
	Возврат Новый ФиксированнаяСтруктура(ПодключаемыеКоманды.КэшФормы(ИмяФормы, ИсточникиЧерезЗапятую, ЭтоФормаОбъекта));
КонецФункции

Функция Параметры() Экспорт
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	
	Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы("СтандартныеПодсистемы.ПодключаемыеКоманды");
	Если Параметры = Неопределено Тогда
		ПодключаемыеКоманды.ОперативноеОбновлениеОбщихДанныхКонфигурации();
		Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы("СтандартныеПодсистемы.ПодключаемыеКоманды");
		Если Параметры = Неопределено Тогда
			Возврат Новый ФиксированнаяСтруктура("ПодключенныеОбъекты", Новый Соответствие);
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ВерсияРасширений) Тогда
		ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПодключаемыеКоманды.ПолноеИмяПодсистемы());
		Если ПараметрыРасширений = Неопределено Тогда
			ПодключаемыеКоманды.ПриЗаполненииВсехПараметровРаботыРасширений();
			ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПодключаемыеКоманды.ПолноеИмяПодсистемы());
			Если ПараметрыРасширений = Неопределено Тогда
				Возврат Новый ФиксированнаяСтруктура(Параметры);
			КонецЕсли;
		КонецЕсли;
		ДополнитьСоответствиеСМассивами(Параметры.ПодключенныеОбъекты, ПараметрыРасширений.ПодключенныеОбъекты);
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	Возврат Новый ФиксированнаяСтруктура(Параметры);
КонецФункции

Процедура ДополнитьСоответствиеСМассивами(СоответствиеПриемник, СоответствиеИсточник)
	Для Каждого КлючИЗначение Из СоответствиеИсточник Цикл
		МассивПриемника = СоответствиеПриемник[КлючИЗначение.Ключ];
		Если МассивПриемника = Неопределено Тогда
			СоответствиеПриемник[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
		Иначе
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивПриемника, КлючИЗначение.Значение, Истина);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция ВидыКоманд() Экспорт
	
	ВидыКоманд = Новый ТаблицаЗначений;
	ВидыКоманд.Колонки.Добавить("Имя", Новый ОписаниеТипов("Строка"));
	ВидыКоманд.Колонки.Добавить("ИмяПодменю", Новый ОписаниеТипов("Строка"));
	ВидыКоманд.Колонки.Добавить("Заголовок", Новый ОписаниеТипов("Строка"));
	ВидыКоманд.Колонки.Добавить("Порядок", Новый ОписаниеТипов("Число"));
	ВидыКоманд.Колонки.Добавить("Картинка", Новый ОписаниеТипов("Картинка"));
	ВидыКоманд.Колонки.Добавить("Отображение", Новый ОписаниеТипов("ОтображениеКнопки, ОтображениеГруппыКнопок"));
	ВидыКоманд.Колонки.Добавить("ВидГруппыФормы");
	
	ЗаполнениеОбъектов.ПриОпределенииВидовПодключаемыхКоманд(ВидыКоманд);
	СозданиеНаОсновании.ПриОпределенииВидовПодключаемыхКоманд(ВидыКоманд);
	ИнтеграцияПодсистемБСП.ПриОпределенииВидовПодключаемыхКоманд(ВидыКоманд);
	ПодключаемыеКомандыПереопределяемый.ПриОпределенииВидовПодключаемыхКоманд(ВидыКоманд);
	
	Для Каждого ВидКоманд Из ВидыКоманд Цикл
		ПодключаемыеКоманды.ПроверитьИмяВидаКоманд(ВидКоманд.Имя);
		Если Не ЗначениеЗаполнено(ВидКоманд.ИмяПодменю) Тогда
			ВидКоманд.ИмяПодменю = "Подменю" + ВидКоманд.Имя;
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ВидКоманд.Заголовок) Тогда
			ВидКоманд.Заголовок = ВидКоманд.Имя;
		КонецЕсли;
	КонецЦикла;
	
	ВидКоманд = ВидыКоманд.Добавить();
	ВидКоманд.Имя = "КоманднаяПанель";
	ВидКоманд.ИмяПодменю = "";
	ВидКоманд.Порядок = 90;
	
	ВидыКоманд.Сортировать("Порядок Возр");
	
	Возврат ВидыКоманд;
	
КонецФункции

#КонецОбласти
