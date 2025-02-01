///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьОформлениеДанных();
	
	ПараметрыЗагрузки = Параметры.ПараметрыЗагрузки;

	ИмяОбъектаСопоставления = Параметры.ИмяОбъектаСопоставления;
	Если Параметры.Свойство("ИнформацияПоКолонкам") Тогда
		СписокКолонок.Загрузить(Параметры.ИнформацияПоКолонкам.Выгрузить());
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СписокКолонокПриАктивизацииСтроки(Элемент)
	Если Элемент.ТекущиеДанные <> Неопределено Тогда 
		ОписаниеКолонки = Элемент.ТекущиеДанные.Примечание;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	ПозицияКолонки = 0;
	Для Каждого СтрокаТаблицы Из СписокКолонок Цикл
		Если СтрокаТаблицы.Видимость Тогда
			ПозицияКолонки = ПозицияКолонки + 1;
			СтрокаТаблицы.Позиция = ПозицияКолонки;
		Иначе
			СтрокаТаблицы.Позиция = -1;
		КонецЕсли;
	КонецЦикла;
	Закрыть(СписокКолонок);
КонецПроцедуры

&НаКлиенте
Процедура СброситьНастройки(Команда)
	Оповещение = Новый ОписаниеОповещения("СброситьНастройкиЗавершение", ЭтотОбъект, ИмяОбъектаСопоставления);
	ПоказатьВопрос(Оповещение, НСтр("ru = 'Установить настройки колонок в первоначальное состояние?'"), РежимДиалогаВопрос.ДаНет);
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	Для каждого СтрокаТаблицы Из СписокКолонок Цикл 
		СтрокаТаблицы.Видимость = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)
	Для каждого СтрокаТаблицы Из СписокКолонок Цикл
		Если Не СтрокаТаблицы.ОбязательнаДляЗаполнения Тогда
			СтрокаТаблицы.Видимость = Ложь;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьОформлениеДанных()

	УсловноеОформление.Элементы.Очистить();
	ЭлементУсловногоОформления = УсловноеОформление.Элементы.Добавить();
	ПолеОформления = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("СписокКолонокНаименование");
	ПолеОформления.Использование = Истина;
	ЭлементОтбора = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("СписокКолонок.ОбязательнаДляЗаполнения"); 
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно; 
	ЭлементОтбора.ПравоеЗначение =Истина;
	ЭлементОтбора.Использование = Истина;
	ЭлементУсловногоОформления.Оформление.УстановитьЗначениеПараметра("Шрифт", ШрифтыСтиля.ВажнаяНадписьШрифт);
	
	ЭлементУсловногоОформления = УсловноеОформление.Элементы.Добавить();
	ПолеОформления = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("СписокКолонокВидимость");
	ПолеОформления.Использование = Истина;
	ЭлементОтбора = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("СписокКолонок.ОбязательнаДляЗаполнения"); 
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно; 
	ЭлементОтбора.ПравоеЗначение =Истина;
	ЭлементОтбора.Использование = Истина;
	ЭлементУсловногоОформления.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
	
	ЭлементУсловногоОформления = УсловноеОформление.Элементы.Добавить();
	ПолеОформления = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("СписокКолонокСиноним");
	ПолеОформления.Использование = Истина;
	ЭлементОтбора = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("СписокКолонок.Синоним");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	ЭлементОтбора.Использование = Истина;
	ЭлементУсловногоОформления.Оформление.УстановитьЗначениеПараметра("Текст", НСтр("ru = 'Стандартное наименование'"));
	ЭлементУсловногоОформления.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ТекстЗапрещеннойЯчейкиЦвет);
	
КонецПроцедуры

&НаКлиенте
Процедура СброситьНастройкиЗавершение(РезультатВопроса, ИмяОбъектаСопоставления) Экспорт
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		СброситьНастройкиКолонок(ИмяОбъектаСопоставления);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура СброситьНастройкиКолонок(ИмяОбъектаСопоставления)
	
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ЗагрузкаДанныхИзФайла", ИмяОбъектаСопоставления, Неопределено,, ИмяПользователя());
	
	СписокКолонокТаблица = СписокКолонок.Выгрузить();
	СписокКолонокТаблица.Очистить();
	Обработки.ЗагрузкаДанныхИзФайла.ОпределитьИнформацияПоКолонкам(ПараметрыЗагрузки, СписокКолонокТаблица);
	ЗначениеВРеквизитФормы(СписокКолонокТаблица, "СписокКолонок");
	
КонецПроцедуры

#КонецОбласти
