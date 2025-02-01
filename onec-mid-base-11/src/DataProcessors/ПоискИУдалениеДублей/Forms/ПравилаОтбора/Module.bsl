///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


// Ожидаются параметры:
//
//     ИдентификаторОсновнойФормы      - УникальныйИдентификатор - Идентификатор формы, через хранилище которой
//                                                                 происходит обмен.
//     АдресСхемыКомпоновки            - Строка - Адрес временного хранилища схемы компоновки, для которой
//                                                редактируются настройки.
//     АдресНастроекКомпоновщикаОтбора - Строка - Адрес временного хранилища редактируемых настроек компоновщика.
//     ПредставлениеОбластиОтбора      - Строка - Представление для формирования заголовка.
//
// Возвращается результатом выбора:
//
//     Неопределено - Отказ от редактирования.
//     Строка       - Адрес временного хранилища новых настроек компоновщика.
//

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИдентификаторОсновнойФормы = Параметры.ИдентификаторОсновнойФормы;
	
	КомпоновщикПредварительногоОтбора = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикПредварительногоОтбора.Инициализировать( 
		Новый ИсточникДоступныхНастроекКомпоновкиДанных(Параметры.АдресСхемыКомпоновки) );
		
	АдресНастроекКомпоновщикаОтбора = Параметры.АдресНастроекКомпоновщикаОтбора;
	КомпоновщикПредварительногоОтбора.ЗагрузитьНастройки(ПолучитьИзВременногоХранилища(АдресНастроекКомпоновщикаОтбора));
	УдалитьИзВременногоХранилища(АдресНастроекКомпоновщикаОтбора);
	
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Правила отбора ""%1""'"), Параметры.ПредставлениеОбластиОтбора);
	
	ЭтоМобильныйКлиент = ОбщегоНазначения.ЭтоМобильныйКлиент();
	Если ЭтоМобильныйКлиент Тогда
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
		Элементы.ГруппаСкрытоНаМобильномКлиенте.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Модифицированность И ЭтоМобильныйКлиент Тогда
		ОповеститьОВыборе(АдресНастроекКомпоновщикаОтбора());
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выбрать(Команда)
	
	Если Модифицированность Тогда
		ОповеститьОВыборе(АдресНастроекКомпоновщикаОтбора());
	Иначе
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция АдресНастроекКомпоновщикаОтбора()
	Возврат ПоместитьВоВременноеХранилище(КомпоновщикПредварительногоОтбора.Настройки, ИдентификаторОсновнойФормы)
КонецФункции


#КонецОбласти

