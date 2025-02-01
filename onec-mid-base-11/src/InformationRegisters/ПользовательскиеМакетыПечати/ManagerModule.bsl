///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Регистрирует на плане обмена ОбновлениеИнформационнойБазы объекты,
// которые необходимо обновить на новую версию.
//
// Параметры:
//  Параметры - Структура - служебный параметр для передачи в процедуру ОбновлениеИнформационнойБазы.ОтметитьКОбработке.
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ПользовательскиеМакетыПечати.ИмяМакета КАК ИмяМакета,
	|	ПользовательскиеМакетыПечати.Объект КАК Объект
	|ИЗ
	|	РегистрСведений.ПользовательскиеМакетыПечати КАК ПользовательскиеМакетыПечати";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	ПользовательскиеМакеты = Запрос.Выполнить().Выгрузить();
	
	ДополнительныеПараметры = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыОтметкиОбработки();
	ДополнительныеПараметры.ЭтоНезависимыйРегистрСведений = Истина;
	ДополнительныеПараметры.ПолноеИмяРегистра = "РегистрСведений.ПользовательскиеМакетыПечати";
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, ПользовательскиеМакеты, ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработатьПользовательскиеМакеты(Параметры) Экспорт
	
	ОбъектовОбработано = 0;
	ПроблемныхОбъектов = 0;
	
	МакетыВФорматеDOCX = Новый Массив;
	ИнтеграцияПодсистемБСП.ПриПодготовкеСпискаМакетовВФорматеОфисныхДокументовФормируемыхНаСервере(МакетыВФорматеDOCX);
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьИзмеренияНезависимогоРегистраСведенийДляОбработки(
		Параметры.Очередь, "РегистрСведений.ПользовательскиеМакетыПечати");
		
	Пока Выборка.Следующий() Цикл
		Запись = СоздатьМенеджерЗаписи();
		Запись.ИмяМакета = Выборка.ИмяМакета;
		Запись.Объект = Выборка.Объект;
		Запись.Прочитать();
		ИзмененныйМакет = Запись.Макет.Получить();
		
		ЭтоОбщийМакет = СтрРазделить(Выборка.Объект, ".", Истина).Количество() < 2;
		
		Если ЭтоОбщийМакет Тогда
			ИмяОбъектаМетаданныхМакета = "ОбщийМакет." + Выборка.ИмяМакета;
		Иначе
			ИмяОбъектаМетаданныхМакета = Выборка.Объект + ".Макет." + Выборка.ИмяМакета;
		КонецЕсли;
		
		ПолноеИмяМакета = Выборка.Объект + "." + Выборка.ИмяМакета;
		
		НаборЗаписей = СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Объект.Установить(Выборка.Объект);
		НаборЗаписей.Отбор.ИмяМакета.Установить(Выборка.ИмяМакета);
		
		Если Метаданные.НайтиПоПолномуИмени(ИмяОбъектаМетаданныхМакета) = Неопределено Тогда
			ИмяСобытия = НСтр("ru = 'Печать'", ОбщегоНазначения.КодОсновногоЯзыка());
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Обнаружен пользовательский макет, отсутствующий в метаданных конфигурации:
					|""%1"".'"), ИмяОбъектаМетаданныхМакета);
			ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Предупреждение, , ИмяОбъектаМетаданныхМакета, ТекстОшибки);
			ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(НаборЗаписей);
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			Продолжить;
		КонецЕсли;
		
		Если ЭтоОбщийМакет Тогда
			МакетИзМетаданных = ПолучитьОбщийМакет(Выборка.ИмяМакета);
		Иначе
			УстановитьОтключениеБезопасногоРежима(Истина);
			УстановитьПривилегированныйРежим(Истина);
		
			МакетИзМетаданных = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(Выборка.Объект).ПолучитьМакет(Выборка.ИмяМакета);
			
			УстановитьПривилегированныйРежим(Ложь);
			УстановитьОтключениеБезопасногоРежима(Ложь);
		КонецЕсли;
		
		Если Не УправлениеПечатью.МакетыРазличаются(МакетИзМетаданных, ИзмененныйМакет) Тогда
			ОбновлениеИнформационнойБазы.ЗаписатьДанные(НаборЗаписей);
		ИначеЕсли МакетыВФорматеDOCX.Найти(ПолноеИмяМакета) <> Неопределено
			И ТипЗнч(МакетИзМетаданных) = Тип("ДвоичныеДанные") И ТипЗнч(ИзмененныйМакет) = Тип("ДвоичныеДанные")
			И ТипыМакетовОфисныхДокументовРазличаются(МакетИзМетаданных, ИзмененныйМакет) Тогда
			УправлениеПечатью.ОтключитьПользовательскийМакет(ПолноеИмяМакета);
		Иначе
			ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(НаборЗаписей);
		КонецЕсли;
		ОбъектовОбработано = ОбъектовОбработано + 1;
	КонецЦикла;
	
	Параметры.ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "РегистрСведений.ПользовательскиеМакетыПечати");
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось обработать некоторые пользовательские макеты (пропущены): %1'"),
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Информация, Метаданные.РегистрыСведений.ПользовательскиеМакетыПечати,,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Обработана очередная порция пользовательских макетов: %1'"),
			ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьКлючЗаписиМакета(ИдентификаторМакета) Экспорт
	МассивСловИдентификатора = СтрРазделить(ИдентификаторМакета, ".", Ложь);
		
	ИмяМакета = МассивСловИдентификатора[МассивСловИдентификатора.ВГраница()];
	МассивСловИдентификатора.Удалить(МассивСловИдентификатора.ВГраница());
	ИмяОбъекта = СтрСоединить(МассивСловИдентификатора, ".");
	
	ТекстЗапроса = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ПользовательскиеМакетыПечати.Объект КАК Объект,
		|	ПользовательскиеМакетыПечати.ИмяМакета КАК ИмяМакета
		|ИЗ
		|	РегистрСведений.ПользовательскиеМакетыПечати КАК ПользовательскиеМакетыПечати
		|ГДЕ
		|	ПользовательскиеМакетыПечати.Объект = &Объект
		|	И ПользовательскиеМакетыПечати.ИмяМакета ПОДОБНО &ИмяМакета
		|	И ПользовательскиеМакетыПечати.Использование";
		
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.Параметры.Вставить("Объект", ИмяОбъекта);
		Запрос.Параметры.Вставить("ИмяМакета", ИмяМакета + "%");
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		
		Если Выборка.Следующий() Тогда
			СтруктураКлюча = Новый Структура("Объект, ИмяМакета");			
			ЗаполнитьЗначенияСвойств(СтруктураКлюча, Выборка);
			КлючОбъектаРедактирования = СоздатьКлючЗаписи(СтруктураКлюча);
			Возврат КлючОбъектаРедактирования;
		Иначе
			Возврат Неопределено
		КонецЕсли;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ТипыМакетовОфисныхДокументовРазличаются(ИсходныйМакет, ИзмененныйМакет)
	
	Возврат УправлениеПечатьюСлужебный.ОпределитьРасширениеФайлаДанныхПоСигнатуре(ИсходныйМакет) <> УправлениеПечатьюСлужебный.ОпределитьРасширениеФайлаДанныхПоСигнатуре(ИзмененныйМакет);
	
КонецФункции

Процедура УстановитьИспользованиеИзмененныхМакетов(Макеты, ИспользуетсяИзмененный) Экспорт
	
	ТаблицаДляПоиска = Новый ТаблицаЗначений;
	ТаблицаДляПоиска.Колонки.Добавить("ИмяМакета", Новый ОписаниеТипов("Строка", ,
	   Новый КвалификаторыСтроки(100, ДопустимаяДлина.Переменная)));
	ТаблицаДляПоиска.Колонки.Добавить("ИмяВладельца", Новый ОписаниеТипов("Строка", ,
	   Новый КвалификаторыСтроки(255, ДопустимаяДлина.Переменная)));
	
	Для Каждого ИмяОбъектаМетаданныхМакета Из Макеты Цикл
		СтрокаТаблицы = ТаблицаДляПоиска.Добавить();
		ЧастиИмени = СтрРазделить(ИмяОбъектаМетаданныхМакета, ".");
		СтрокаТаблицы.ИмяМакета = ЧастиИмени[ЧастиИмени.ВГраница()];
		
		ИмяВладельца = "";
		Для НомерЧасти = 0 По ЧастиИмени.ВГраница()-1 Цикл
			Если Не ПустаяСтрока(ИмяВладельца) Тогда
				ИмяВладельца = ИмяВладельца + ".";
			КонецЕсли;
			ИмяВладельца = ИмяВладельца + ЧастиИмени[НомерЧасти];
		КонецЦикла;
		
		СтрокаТаблицы.ИмяВладельца = ИмяВладельца;
	КонецЦикла;
		
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ТаблицаДляПоиска.ИмяМакета ИмяМакета,
	|	ТаблицаДляПоиска.ИмяВладельца ИмяВладельца
	|ПОМЕСТИТЬ ВТТаблицаДляПоиска
	|ИЗ
	|	&ТаблицаДляПоиска КАК ТаблицаДляПоиска
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаДляПоиска.ИмяВладельца,
	|	ТаблицаДляПоиска.ИмяМакета КАК ИмяМакетаДляПоиска,
	|	ПользовательскиеМакетыПечати.ИмяМакета
	|ИЗ
	|	ВТТаблицаДляПоиска КАК ТаблицаДляПоиска
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПользовательскиеМакетыПечати КАК ПользовательскиеМакетыПечати
	|		ПО ПользовательскиеМакетыПечати.Объект = ТаблицаДляПоиска.ИмяВладельца";
	 
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("ТаблицаДляПоиска", ТаблицаДляПоиска);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Если СтрНачинаетсяС(Выборка.ИмяМакета, Выборка.ИмяМакетаДляПоиска) Тогда
			Запись = СоздатьМенеджерЗаписи();
			Запись.Объект = Выборка.ИмяВладельца;
			Запись.ИмяМакета = Выборка.ИмяМакета;
			Запись.Прочитать();
			Если Запись.Выбран() Тогда
				Запись.Использование = ИспользуетсяИзмененный;
				Запись.Записать();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
//  ИмяОбъекта - Строка
//
Функция МакетыОбъекта(ИмяОбъекта) Экспорт
	
	Если ИмяОбъекта = "ОбщиеМакеты" Тогда
		ИдентификаторОбъектаМетаданных = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	Иначе
		ИдентификаторОбъектаМетаданных = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ИмяОбъекта);
	КонецЕсли;
	
	Возврат МакетыОбъектов(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ИдентификаторОбъектаМетаданных));
	
КонецФункции

// Возвращаемое значение:
//  ТаблицаЗначений
//
Функция МакетыОбъектов(ИдентификаторыОбъектовМетаданных) Экспорт
	
	СписокМакетов = Новый ТаблицаЗначений();
	СписокМакетов.Колонки.Добавить("ИсточникМакета");
	СписокМакетов.Колонки.Добавить("ИсточникиДанных");
	СписокМакетов.Колонки.Добавить("Идентификатор");
	СписокМакетов.Колонки.Добавить("Представление");
	СписокМакетов.Колонки.Добавить("Владелец");
	СписокМакетов.Колонки.Добавить("ТипМакета");
	СписокМакетов.Колонки.Добавить("Картинка");
	СписокМакетов.Колонки.Добавить("КартинкаГруппы");
	СписокМакетов.Колонки.Добавить("СтрокаПоиска");
	СписокМакетов.Колонки.Добавить("ДоступныеЯзыки");
	СписокМакетов.Колонки.Добавить("Изменен");
	СписокМакетов.Колонки.Добавить("ИспользуетсяИзмененный");
	СписокМакетов.Колонки.Добавить("КартинкаИспользования");
	СписокМакетов.Колонки.Добавить("ДоступенПеревод");
	СписокМакетов.Колонки.Добавить("Ссылка");
	СписокМакетов.Колонки.Добавить("Используется");
	СписокМакетов.Колонки.Добавить("ДоступнаНастройкаВидимости");
	СписокМакетов.Колонки.Добавить("Поставляемый");
	СписокМакетов.Колонки.Добавить("ЭтоПечатнаяФорма");
	СписокМакетов.Колонки.Добавить("ДоступноСоздание");
	СписокМакетов.Колонки.Добавить("ИмяОбъектаМетаданныхМакета");
	
	СписокМакетов.Индексы.Добавить("Владелец");
	
	ДобавитьПользовательскиеМакеты(СписокМакетов, , ИдентификаторыОбъектовМетаданных);
	ДобавитьМакетыИзМетаданных(СписокМакетов, ИдентификаторыОбъектовМетаданных);
	
	СписокМакетов.Сортировать("Представление");
	
	Возврат СписокМакетов;
	
КонецФункции

Процедура ДобавитьМакетыИзМетаданных(СписокМакетов, ИдентификаторыОбъектовМетаданных)
	
	ОбъектыМетаданныхПоИдентификаторам = ОбщегоНазначения.ОбъектыМетаданныхПоИдентификаторам(ИдентификаторыОбъектовМетаданных, Ложь);
	Если ИдентификаторыОбъектовМетаданных.Найти(Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка()) <> Неопределено Тогда
		ОбъектыМетаданныхПоИдентификаторам.Вставить(Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка(), Метаданные.ОбщиеМакеты);
	КонецЕсли;
	
	ОбъектыМетаданных = Новый Массив;
	Для Каждого ОписаниеОбъектаМетаданных Из ОбъектыМетаданныхПоИдентификаторам Цикл
		ОбъектМетаданных = ОписаниеОбъектаМетаданных.Значение;
		ОбъектыМетаданных.Добавить(ОбъектМетаданных);
	КонецЦикла;
	
	ИзмененныеМакеты = ИзмененныеМакеты();
	
	ДоступныеДляПереводаМакеты = Новый Соответствие;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		ДоступныеДляПереводаМакеты = МодульУправлениеПечатьюМультиязычность.ДоступныеДляПереводаМакеты();
	КонецЕсли;
	
	Для Каждого ОписаниеОбъектаМетаданных Из ОбъектыМетаданныхПоИдентификаторам Цикл

		ОбъектМетаданныхВладелецМакета = ОписаниеОбъектаМетаданных.Значение;
		Владелец =  ?(Метаданные.ОбщиеМакеты = ОбъектМетаданныхВладелецМакета, 
					Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка(), ОписаниеОбъектаМетаданных.Ключ);

		КоллекцииМакетов = Новый Массив;
		Если Метаданные.ОбщиеМакеты = ОбъектМетаданныхВладелецМакета Тогда
			КоллекцииМакетов.Добавить(Метаданные.ОбщиеМакеты);
		Иначе
			КоллекцииМакетов.Добавить(ОбъектМетаданныхВладелецМакета.Макеты);
			ПодключенныеМакеты = ПодключенныеМакеты(ОписаниеОбъектаМетаданных.Ключ);
			КоллекцииМакетов.Добавить(ПодключенныеМакеты);
		КонецЕсли;
		
		Для Каждого КоллекцияМакетов Из КоллекцииМакетов Цикл
			Для Каждого Элемент Из КоллекцияМакетов Цикл
				ИмяВладельца = ?(Метаданные.ОбщиеМакеты = ОбъектМетаданныхВладелецМакета, 
					"ОбщийМакет", ОбъектМетаданныхВладелецМакета.ПолноеИмя());
				
				ОбъектМетаданныхМакет = Элемент;
				ИсточникМакета = ИмяВладельца;
				ИсточникиДанных = ИмяВладельца;
				
				Если ТипЗнч(КоллекцияМакетов) = Тип("ТаблицаЗначений") Тогда
					ОбъектМетаданныхМакет = Элемент.ОбъектМетаданных;
					ИсточникМакета = Элемент.ИсточникМакета;
					ИсточникиДанных = Элемент.ИсточникиДанных;
				КонецЕсли;
				
				Если Не СтрНайти(ОбъектМетаданныхМакет.Имя, "ПФ_") Тогда
					Продолжить;
				КонецЕсли;
				
				ИмяОбъектаМетаданныхМакета = ИсточникМакета + "." + ОбъектМетаданныхМакет.Имя;
				ПредставлениеМакета = ОбъектМетаданныхМакет.Представление();
				
				ТипМакета = ТипМакета(ОбъектМетаданныхМакет.Имя, ИсточникМакета);
				
				Макет = СписокМакетов.Добавить();
				Макет.ИсточникМакета = ИсточникМакета;
				Макет.ИсточникиДанных = ИсточникиДанных;
				Макет.Идентификатор = ИмяОбъектаМетаданныхМакета;
				Макет.Представление = ПредставлениеМакета;
				Макет.Владелец = Владелец;
				Макет.ТипМакета = ТипМакета;
				Макет.Картинка = ИндексКартинки(ТипМакета);
				Макет.КартинкаГруппы = КартинкаМакета(ТипМакета);
				Макет.Изменен = ИзмененныеМакеты[ИмяОбъектаМетаданныхМакета] <> Неопределено;
				Макет.ИспользуетсяИзмененный = Макет.Изменен И ИзмененныеМакеты[ИмяОбъектаМетаданныхМакета];
				Макет.ДоступенПеревод = ДоступныеДляПереводаМакеты[ОбъектМетаданныхМакет] = Истина;
				Макет.Используется = Истина;
				Макет.Поставляемый = Истина;
	
				Если ЗначениеЗаполнено(Макет.Владелец) Тогда
					Макет.ЭтоПечатнаяФорма = УправлениеПечатью.ЭтоПечатнаяФорма(Макет.Идентификатор, Макет.Владелец);
					Макет.ДоступенПеревод = Макет.ДоступенПеревод Или Макет.ЭтоПечатнаяФорма;
				КонецЕсли;
				
				Макет.ИмяОбъектаМетаданныхМакета = Макет.Идентификатор;
				Макет.ДоступныеЯзыки = ДоступныеЯзыкиМакета(Макет.Идентификатор);
				Макет.КартинкаИспользования = -1;
				Если Макет.Изменен Тогда
					Макет.КартинкаИспользования = Число(Макет.Изменен) + Число(Макет.ИспользуетсяИзмененный);
				КонецЕсли;
				Макет.СтрокаПоиска = НРег(Макет.Представление + " " + Макет.ТипМакета);
				Макет.ДоступноСоздание = ОбъектМетаданныхВладелецМакета <> Метаданные.ОбщиеМакеты 
					И ОбщегоНазначения.ЭтоОбъектСсылочногоТипа(ОбъектМетаданныхВладелецМакета);
				
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Функция ПодключенныеМакеты(ИдентификаторОбъектаМетаданных)
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("ОбъектМетаданных");
	Результат.Колонки.Добавить("ИсточникМакета");
	Результат.Колонки.Добавить("ИсточникиДанных");
	
	Если ТипЗнч(ИдентификаторОбъектаМетаданных) <> Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
		Возврат Результат;
	КонецЕсли;
	
	ПодключенныеОтчетыИОбработки = ПодключаемыеКоманды.ПодключенныеОбъекты(ИдентификаторОбъектаМетаданных);
	Для Каждого ПодключенныйОбъект Из ПодключенныеОтчетыИОбработки Цикл
		ИсточникиДанных = Новый Массив;
		Для Каждого ОбъектМетаданных Из ПодключенныйОбъект.Размещение Цикл
			ИсточникиДанных.Добавить(ОбъектМетаданных.ПолноеИмя());
		КонецЦикла;
		Для Каждого Макет Из ПодключенныйОбъект.Метаданные.Макеты Цикл
			Если СтрНачинаетсяС(Макет.Имя, "ПФ_") Тогда
				ОписаниеМакета = Результат.Добавить();
				ОписаниеМакета.ОбъектМетаданных = Макет;
				ОписаниеМакета.ИсточникМакета = ПодключенныйОбъект.Метаданные.ПолноеИмя();
				ОписаниеМакета.ИсточникиДанных = СтрСоединить(ИсточникиДанных, ",");
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ИзмененныеМакеты(ОбъектыМетаданных = Неопределено)
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ИзмененныеМакеты.ИмяМакета,
	|	ИзмененныеМакеты.Объект,
	|	ИзмененныеМакеты.Использование
	|ИЗ
	|	РегистрСведений.ПользовательскиеМакетыПечати КАК ИзмененныеМакеты
	|ГДЕ
	|	НЕ &ОтборУстановлен
	|	ИЛИ ИзмененныеМакеты.Объект В(&Объекты)";
	
	ИменаОбъектов = Неопределено;
	Если ОбъектыМетаданных <> Неопределено Тогда
		ИменаОбъектов = Новый Массив;
		Для Каждого ОбъектМетаданных Из ОбъектыМетаданных Цикл
			ИменаОбъектов.Добавить(ОбъектМетаданных.ПолноеИмя());
		КонецЦикла;
	КонецЕсли;
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ОтборУстановлен", ЗначениеЗаполнено(ИменаОбъектов));
	Запрос.УстановитьПараметр("Объекты", ИменаОбъектов);
	ИзмененныеМакеты = Запрос.Выполнить().Выгрузить();
	
	ЯзыкиПечатныхФорм = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ОбщегоНазначения.КодОсновногоЯзыка());
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		ЯзыкиПечатныхФорм = МодульУправлениеПечатьюМультиязычность.ДоступныеЯзыки();
	КонецЕсли;
	
	Результат = Новый Соответствие;
	
	Для Каждого Макет Из ИзмененныеМакеты Цикл
		ИмяМакета = Макет.ИмяМакета;
		
		ИменаМакета = Новый Массив;
		ИменаМакета.Добавить(ИмяМакета);
		
		Для Каждого КодЯзыка Из ЯзыкиПечатныхФорм Цикл
			Если СтрНайти(ИмяМакета, "_MXL_") И СтрЗаканчиваетсяНа(ИмяМакета, "_" + КодЯзыка) Тогда
				ИмяМакета = Лев(ИмяМакета, СтрДлина(ИмяМакета) - СтрДлина(КодЯзыка) - 1);
				ИменаМакета.Добавить(ИмяМакета);
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого ИмяМакета Из ИменаМакета Цикл
			ИмяОбъектаМетаданныхМакета = Макет.Объект + "." + ИмяМакета;
			Результат.Вставить(ИмяОбъектаМетаданныхМакета, Макет.Использование);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ДобавитьПользовательскиеМакеты(СписокМакетов, Знач Идентификатор = Неопределено, Знач ИсточникиДанных = Неопределено) Экспорт
	
	Если ЗначениеЗаполнено(Идентификатор) Тогда
		Идентификатор = Новый УникальныйИдентификатор(Сред(Идентификатор, 4));
	Иначе
		Идентификатор = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	МакетыПечатныхФорм.Ссылка,
	|	МакетыПечатныхФорм.Представление,
	|	МакетыПечатныхФорм.Используется,
	|	МакетыПечатныхФорм.ТипМакета,
	|	МакетыПечатныхФорм.Идентификатор,
	|	МакетыПечатныхФормИсточникиДанных.ИсточникДанных КАК Владелец
	|ИЗ
	|	Справочник.МакетыПечатныхФорм.ИсточникиДанных КАК МакетыПечатныхФормИсточникиДанных
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.МакетыПечатныхФорм КАК МакетыПечатныхФорм
	|		ПО МакетыПечатныхФормИсточникиДанных.Ссылка = МакетыПечатныхФорм.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
	|		ПО МакетыПечатныхФормИсточникиДанных.Ссылка = ИдентификаторыОбъектовМетаданных.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовРасширений КАК ИдентификаторыОбъектовРасширений
	|		ПО МакетыПечатныхФормИсточникиДанных.Ссылка = ИдентификаторыОбъектовРасширений.Ссылка
	|ГДЕ
	|	НЕ МакетыПечатныхФорм.ПометкаУдаления
	|	И ((НЕ &ОтборПоИсточникамДанныхУстановлен
	|	ИЛИ МакетыПечатныхФормИсточникиДанных.ИсточникДанных В (&ИсточникиДанных))
	|	И (НЕ &ОтборПоИдентификаторуУстановлен
	|	ИЛИ МакетыПечатныхФорм.Идентификатор = &Идентификатор))";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ОтборПоИдентификаторуУстановлен", ЗначениеЗаполнено(Идентификатор));
	Запрос.УстановитьПараметр("Идентификатор", Идентификатор);
	Запрос.УстановитьПараметр("ОтборПоИсточникамДанныхУстановлен", ИсточникиДанных <> Неопределено);
	Запрос.УстановитьПараметр("ИсточникиДанных", ИсточникиДанных);
	
	ТаблицаМакетов = Запрос.Выполнить().Выгрузить();
	Для Каждого СтрокаТаблицы Из ТаблицаМакетов Цикл
		Макет = СписокМакетов.Добавить();
		ЗаполнитьЗначенияСвойств(Макет, СтрокаТаблицы);
		
		НайденныеСтроки = ТаблицаМакетов.НайтиСтроки(Новый Структура("Идентификатор", Макет.Идентификатор));
		ИсточникиДанных = Новый Массив;
		Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
			ИсточникиДанных.Добавить(НайденнаяСтрока.Владелец);
		КонецЦикла;
		
		ОбъектыМетаданныхПоИдентификаторам = ОбщегоНазначения.ОбъектыМетаданныхПоИдентификаторам(ИсточникиДанных, Ложь);
		
		ИсточникиДанных = Новый Массив;
		Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхПоИдентификаторам Цикл
			Если ОбъектМетаданных.Значение <> Неопределено Тогда
				ИсточникиДанных.Добавить(ОбъектМетаданных.Значение.ПолноеИмя());
			КонецЕсли;
		КонецЦикла;
		
		Макет.ИсточникиДанных = СтрСоединить(ИсточникиДанных, ",");
		Макет.Изменен = Истина;
		Макет.ИспользуетсяИзмененный = Истина;
		Макет.ДоступенПеревод = Истина;
		Макет.Идентификатор = "ПФ_" + Строка(Макет.Идентификатор);
		Макет.ДоступнаНастройкаВидимости = Истина;
		Макет.ЭтоПечатнаяФорма = Истина;
		
		Макет.ИмяОбъектаМетаданныхМакета = Макет.Идентификатор;
		Макет.ДоступныеЯзыки = ДоступныеЯзыкиМакета(Макет.Идентификатор);

		Макет.Картинка = ИндексКартинки(Макет.ТипМакета);
		Макет.КартинкаГруппы = КартинкаМакета(Макет.ТипМакета);
		Макет.КартинкаИспользования = -1;

		Если Макет.Изменен Тогда
			Макет.КартинкаИспользования = Число(Макет.Изменен) + Число(Макет.ИспользуетсяИзмененный);
		КонецЕсли;
		Макет.СтрокаПоиска = НРег(Макет.Представление + " " + Макет.ТипМакета);
		Если ЗначениеЗаполнено(Макет.Владелец) Тогда
			ОбъектМетаданныхВладелецМакета = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(Макет.Владелец);
			Макет.ДоступноСоздание = ОбщегоНазначения.ЭтоОбъектСсылочногоТипа(ОбъектМетаданныхВладелецМакета);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Функция ДоступныеЯзыкиМакета(Знач ИмяОбъектаМетаданныхМакета) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		Возврат МодульУправлениеПечатьюМультиязычность.ПредставлениеЯзыковМакета(ИмяОбъектаМетаданныхМакета);
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

Функция ТипМакета(ИмяОбъектаМетаданныхМакета, ИмяОбъекта = "ОбщийМакет")
	
	Позиция = СтрНайти(ИмяОбъектаМетаданныхМакета, "ПФ_");
	Если Позиция = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ИмяОбъекта = "ОбщийМакет" Тогда
		МакетПечатнойФормы = ПолучитьОбщийМакет(ИмяОбъектаМетаданныхМакета);
	Иначе
		УстановитьОтключениеБезопасногоРежима(Истина);
		УстановитьПривилегированныйРежим(Истина);
		
		МакетПечатнойФормы = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ИмяОбъекта).ПолучитьМакет(ИмяОбъектаМетаданныхМакета);
		
		УстановитьПривилегированныйРежим(Ложь);
		УстановитьОтключениеБезопасногоРежима(Ложь);
	КонецЕсли;
	
	ТипМакета = Неопределено;
	
	Если ТипЗнч(МакетПечатнойФормы) = Тип("ТабличныйДокумент") Тогда
		ТипМакета = "MXL";
	ИначеЕсли ТипЗнч(МакетПечатнойФормы) = Тип("ДвоичныеДанные") Тогда
		ТипМакета = ВРег(УправлениеПечатьюСлужебный.ОпределитьРасширениеФайлаДанныхПоСигнатуре(МакетПечатнойФормы));
	КонецЕсли;
	
	Возврат ТипМакета;
	
КонецФункции

Функция ИндексКартинки(Знач ТипМакета) Экспорт
	
	ТипыМакетов = Новый Соответствие;
	ТипыМакетов.Вставить("DOC", 0);
	ТипыМакетов.Вставить("DOCX", 0);
	ТипыМакетов.Вставить("ODT", 1);
	ТипыМакетов.Вставить("MXL", 2);
	
	Результат = ТипыМакетов[ВРег(ТипМакета)];
	Возврат ?(Результат = Неопределено, -1, Результат);
	
КонецФункции 

Функция КартинкаМакета(Знач ТипМакета)
	
	ТипыМакетов = Новый Соответствие;
	ТипыМакетов.Вставить("DOC", БиблиотекаКартинок.ФорматWord);
	ТипыМакетов.Вставить("DOCX", БиблиотекаКартинок.ФорматWord2007);
	ТипыМакетов.Вставить("ODT", БиблиотекаКартинок.ФорматOpenOfficeCalc);
	ТипыМакетов.Вставить("MXL", БиблиотекаКартинок.ФорматMXL);
	
	Результат = ТипыМакетов[ВРег(ТипМакета)];
	Возврат ?(Результат = Неопределено, Новый Картинка, Результат);
	
КонецФункции 

#КонецОбласти

#КонецЕсли
