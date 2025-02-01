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
	
	Если ЗначениеЗаполнено(Параметры.РежимВыполнения) Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "РежимВыполнения", Параметры.РежимВыполнения);
		ОтборРежимВыполнения = Параметры.РежимВыполнения;
	КонецЕсли;
	
	ДоступноИспользованиеРазделенныхДанных = ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных();
	
	Если ДоступноИспользованиеРазделенныхДанных
		И Пользователи.ЭтоПолноправныйПользователь() Тогда
		Элементы.ОбластьДанныхВспомогательныеДанные.Видимость = Ложь;
	КонецЕсли;

	Элементы.ПрогрессОбновленияОбластейДанных.Видимость = Не ДоступноИспользованиеРазделенныхДанных;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ОбновлениеВерсииИБВМоделиСервиса") Тогда
		МодульОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("ОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса");
		ОтчетПрогрессОбновления = МодульОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса.ОтчетПрогрессОбновления();
		УстановитьТекстЗапроса();
	Иначе
		Элементы.ПрогрессОбновленияОбластейДанных.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ВРег(ИмяСобытия) = ВРег("Запись_ОбработчикиОбновления") Тогда
		Элементы.Список.Обновить();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОтборСтатусПриИзменении(Элемент)
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Статус", ОтборСтатус, , , ЗначениеЗаполнено(ОтборСтатус));
КонецПроцедуры

&НаКлиенте
Процедура ОтборРежимВыполненияПриИзменении(Элемент)
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "РежимВыполнения", ОтборРежимВыполнения, , , ЗначениеЗаполнено(ОтборРежимВыполнения));
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Если Элемент.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяОбработчика = Элемент.ТекущиеДанные.ИмяОбработчика;
	Отбор = Новый Структура("ИмяОбработчика", ИмяОбработчика);
	Если Не ДоступноИспользованиеРазделенныхДанных Тогда
		Отбор.Вставить("ОбластьДанныхВспомогательныеДанные", Элемент.ТекущиеДанные.ОбластьДанныхВспомогательныеДанные);
	КонецЕсли;
	
	ТипЗначения = Тип("РегистрСведенийКлючЗаписи.ОбработчикиОбновления");
	ПараметрыЗаписи = Новый Массив(1);
	ПараметрыЗаписи[0] = Отбор;
	
	КлючЗаписи = КлючЗаписи(ТипЗначения, ПараметрыЗаписи);
	ПоказатьЗначение(Неопределено, КлючЗаписи);
КонецПроцедуры

&НаСервере
Функция КлючЗаписи(ТипЗначения, ПараметрыЗаписи)
	
	Возврат Новый(ТипЗначения, ПараметрыЗаписи);
	
КонецФункции

&НаКлиенте
Процедура ПрогрессОбновленияОбластейДанныхНажатие(Элемент)
	ОткрытьФорму(ОтчетПрогрессОбновления);
КонецПроцедуры

&НаСервере
Процедура УстановитьТекстЗапроса()
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ОбработчикиОбновленияПереопределяемый.ИмяОбработчика,
		|	ОбработчикиОбновленияПереопределяемый.Статус,
		|	ОбработчикиОбновленияПереопределяемый.Версия,
		|	ОбработчикиОбновленияПереопределяемый.ИмяБиблиотеки,
		|	ОбработчикиОбновленияПереопределяемый.ДлительностьОбработки,
		|	ОбработчикиОбновленияПереопределяемый.РежимВыполнения,
		|	ОбработчикиОбновленияПереопределяемый.ВерсияРегистрации,
		|	ОбработчикиОбновленияПереопределяемый.ВерсияПорядок,
		|	ОбработчикиОбновленияПереопределяемый.Идентификатор,
		|	ОбработчикиОбновленияПереопределяемый.ЧислоПопыток,
		|	ОбработчикиОбновленияПереопределяемый.СтатистикаВыполнения,
		|	ОбработчикиОбновленияПереопределяемый.ИнформацияОбОшибке,
		|	ОбработчикиОбновленияПереопределяемый.Комментарий,
		|	ОбработчикиОбновленияПереопределяемый.Приоритет,
		|	ОбработчикиОбновленияПереопределяемый.ПроцедураПроверки,
		|	ОбработчикиОбновленияПереопределяемый.ПроцедураЗаполненияДанныхОбновления,
		|	ОбработчикиОбновленияПереопределяемый.ОчередьОтложеннойОбработки,
		|	ОбработчикиОбновленияПереопределяемый.ЗапускатьТолькоВГлавномУзле,
		|	ОбработчикиОбновленияПереопределяемый.ЗапускатьИВПодчиненномУзлеРИБСФильтрами,
		|	ОбработчикиОбновленияПереопределяемый.Многопоточный,
		|	ОбработчикиОбновленияПереопределяемый.ОбработкаПорцииЗавершена,
		|	ОбработчикиОбновленияПереопределяемый.ГруппаОбновления,
		|	ОбработчикиОбновленияПереопределяемый.ИтерацияЗапуска,
		|	ОбработчикиОбновленияПереопределяемый.ОбрабатываемыеДанные,
		|	ОбработчикиОбновленияПереопределяемый.РежимВыполненияОтложенногоОбработчика,
		|	ОбработчикиОбновленияПереопределяемый.ИзменяемыеОбъекты,
		|	ОбработчикиОбновленияПереопределяемый.ОбластьДанныхВспомогательныеДанные КАК ОбластьДанныхВспомогательныеДанные,
		|	ОбработчикиОбновленияПереопределяемый.ДлительностьРегистрацииДанных
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновленияПереопределяемый";  
	
	СвойстваСписка = ОбщегоНазначения.СтруктураСвойствДинамическогоСписка();
	СвойстваСписка.ТекстЗапроса = ТекстЗапроса;
	ОбщегоНазначения.УстановитьСвойстваДинамическогоСписка(Элементы.Список, СвойстваСписка);
	
КонецПроцедуры

#КонецОбласти

