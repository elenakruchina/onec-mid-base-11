///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область ПрограммныйИнтерфейс

// Отправляет сообщение пользователям от другого пользователя. 
// Если между пользователями не было обсуждения,
// то будет создано отображаемое обсуждение.
//
// Выбрасывает исключение, если не удалось отправить сообщение.
//
// Параметры: 
//   Автор - СправочникСсылка.Пользователи
//         - ПользовательСистемыВзаимодействия
//   Получатели - Массив из СправочникСсылка.Пользователи
//              - Массив из ПользовательСистемыВзаимодействия
//   Сообщение - см. ОписаниеСообщения
//   ОбсуждениеКонтекст - ЛюбаяСсылка - сообщение будет отправлено в контекстное обсуждение.
//                      - ИдентификаторОбсужденияСистемыВзаимодействия - сообщение будет отправлено в указанное обсуждение.
//                      - Неопределено - сообщение будет отправлено в негрупповое обсуждение между автором и получателем.
//
// Пример:
// Сообщение = Обсуждения.ОписаниеСообщения("Привет, мир!");
// Получатель = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Администратор);
// Обсуждения.ОтправитьСообщение(Пользователи.ТекущийПользователь(), Получатель, Сообщение);
//
Процедура ОтправитьСообщение(Знач Автор, Знач Получатели, Сообщение, ОбсуждениеКонтекст = Неопределено) Экспорт
	
	Если ТипЗнч(Автор) <> Тип("ПользовательСистемыВзаимодействия") Тогда
		Автор = ПользовательСистемыВзаимодействия(Автор);
	КонецЕсли;
	
	Если Автор = Неопределено Тогда
		ВызватьИсключение НСтр("ru='Не указан автор сообщения'");
	КонецЕсли;
	
	Если Получатели.Количество() = 0 Тогда
		ВызватьИсключение НСтр("ru='Не указаны получатели сообщения'");
	КонецЕсли;
	
	Если ТипЗнч(Получатели[0]) = Тип("СправочникСсылка.Пользователи") Тогда
		ПолучателиПоСсылкам = ПользователиСистемыВзаимодействия(Получатели);
		Получатели = Новый Массив; // Массив Из ПользовательСистемыВзаимодействия
		Для Каждого КлючИЗначение Из ПолучателиПоСсылкам Цикл
			Получатель = КлючИЗначение.Значение;
			Если ТипЗнч(Получатель) = Тип("ПользовательСистемыВзаимодействия") Тогда
				Получатели.Добавить(Получатель);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ОбсуждениеКонтекст <> Неопределено 
			И ТипЗнч(ОбсуждениеКонтекст) <> Тип("ИдентификаторОбсужденияСистемыВзаимодействия") Тогда
			
		Если НЕ ЗначениеЗаполнено(ОбсуждениеКонтекст) Тогда
			ВызватьИсключение НСтр("ru='Передан пустой контекст обсуждения.'");
		КонецЕсли;
		
		Контекст = Новый КонтекстОбсужденияСистемыВзаимодействия(ПолучитьНавигационнуюСсылку(ОбсуждениеКонтекст));
		Отбор = Новый ОтборОбсужденийСистемыВзаимодействия;
		Отбор.КонтекстОбсуждения = Контекст;
		Отбор.ТекущийПользовательЯвляетсяУчастником = Ложь;
		Отбор.Отображаемое = Истина;
		Отбор.КонтекстноеОбсуждение = Истина;
		Обсуждение = СистемаВзаимодействия.ПолучитьОбсуждения(Отбор);
		Если Обсуждение.Количество() = 0 Тогда
			Обсуждение = СистемаВзаимодействия.СоздатьОбсуждение();
			Обсуждение.КонтекстОбсуждения = Контекст;
			Обсуждение.Отображаемое = Истина;
			Обсуждение.Заголовок = Строка(ОбсуждениеКонтекст);
			Обсуждение.Записать();
		Иначе 
			Обсуждение = Обсуждение[0];
		КонецЕсли;

		ИдентификаторОбсуждения = Обсуждение.Идентификатор;
		
	ИначеЕсли ОбсуждениеКонтекст = Неопределено Тогда
		
		Если Получатели.Количество() = 1 Тогда
			Участник = Получатели[0];
			Обсуждение = НеГрупповоеОбсуждениеМеждуПользователями(Автор.Идентификатор, Участник.Идентификатор);
		Иначе	
			Обсуждение = СистемаВзаимодействия.СоздатьОбсуждение();
			Обсуждение.Заголовок = Сообщение.Текст;
			Обсуждение.Отображаемое = Истина;
			Обсуждение.Групповое = Истина;
			Обсуждение.Участники.Добавить(Автор.Идентификатор);
 			ДобавитьПолучателей(Обсуждение.Участники, Получатели);
			Обсуждение.Записать();
		КонецЕсли;
		
		ИдентификаторОбсуждения = Обсуждение.Идентификатор;
		
	Иначе
		ИдентификаторОбсуждения = ОбсуждениеКонтекст;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СообщениеСВ = СообщениеИзОписания(Автор, ИдентификаторОбсуждения, Получатели, Сообщение);
	СообщениеСВ.Записать();
	
КонецПроцедуры

// Отправляет сообщение всем участникам неконтекстного обсуждения.
// Если обсуждение контекстное, то будет отправление сообщение без адресатов.
//
// Выбрасывает исключение, если не удалось отправить сообщение.
//
// Параметры: 
//   Автор - СправочникСсылка.Пользователи
//         - ПользовательСистемыВзаимодействия
//   Сообщение - см. ОписаниеСообщения.
//   ОбсуждениеКонтекст - ЛюбаяСсылка - сообщение будет отправлено в контекстное обсуждение.
//                      - ИдентификаторОбсужденияСистемыВзаимодействия - сообщение будет отправлено в указанное обсуждение.
//
// Пример:
// Сообщение = Обсуждения.ОписаниеСообщения("Привет, мир!");
// Обсуждения.ОтправитьУведомление(Пользователи.ТекущийПользователь(), Сообщение, ЗаказКлиента);
//
Процедура ОтправитьУведомление(Знач Автор, Сообщение, ОбсуждениеКонтекст) Экспорт

	Если ТипЗнч(Автор) <> Тип("ПользовательСистемыВзаимодействия") Тогда
		Автор = ПользовательСистемыВзаимодействия(Автор);
	КонецЕсли;
	
	Если Автор = Неопределено Тогда
		ВызватьИсключение НСтр("ru='Не указан автор сообщения'");
	КонецЕсли;
	
	Получатели = Новый Массив;
	
	Если ОбсуждениеКонтекст <> Неопределено 
			И ТипЗнч(ОбсуждениеКонтекст) <> Тип("ИдентификаторОбсужденияСистемыВзаимодействия") Тогда
			
		Если НЕ ЗначениеЗаполнено(ОбсуждениеКонтекст) Тогда
			ВызватьИсключение НСтр("ru='Передан пустой контекст обсуждения.'");
		КонецЕсли;	
		
		Контекст = Новый КонтекстОбсужденияСистемыВзаимодействия(ПолучитьНавигационнуюСсылку(ОбсуждениеКонтекст));
		Отбор = Новый ОтборОбсужденийСистемыВзаимодействия;
		Отбор.КонтекстноеОбсуждение = Истина;
		Отбор.КонтекстОбсуждения = Контекст;
		Обсуждение = СистемаВзаимодействия.ПолучитьОбсуждения(Отбор);
		Если Обсуждение.Количество() = 0 Тогда
			Обсуждение = СистемаВзаимодействия.СоздатьОбсуждение();
			Обсуждение.КонтекстОбсуждения = Контекст;
			Обсуждение.Групповое = Истина;
			Обсуждение.Отображаемое = Истина;
			Обсуждение.Заголовок = Строка(ОбсуждениеКонтекст);
			Обсуждение.Записать();
		Иначе 
			Обсуждение = Обсуждение[0];
		КонецЕсли;
		
		ИдентификаторОбсуждения = Обсуждение.Идентификатор;
		Получатели = Обсуждение.Участники;
		
	ИначеЕсли ОбсуждениеКонтекст = Неопределено Тогда
		
		ВызватьИсключение НСтр("ru='Не указан идентификатор обсуждения или контекст.'");
		
	Иначе
		
		ИдентификаторОбсуждения = ОбсуждениеКонтекст;
		Обсуждение = СистемаВзаимодействия.ПолучитьОбсуждение(ИдентификаторОбсуждения);
		Получатели = Обсуждение.Участники;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	СообщениеСВ = СообщениеИзОписания(
					Автор,
					ИдентификаторОбсуждения,
					Получатели,
					Сообщение);
	СообщениеСВ.Записать();

КонецПроцедуры

// Возвращает Истина, если метод ИнформационнаяБазаЗарегистрирована
// объекта СистемаВзаимодействия возвращает Истина и
// использование не заблокировано администратором.
//
// Возвращаемое значение:
//   Булево
//
Функция СистемаВзаимодействийПодключена() Экспорт
	
	// Выполняется быстро без обращения к серверу взаимодействия.
	Зарегистрирована = СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована();
	
	Возврат Зарегистрирована И Не ОбсужденияСлужебный.Заблокированы();
	
КонецФункции

// Возвращает Истина, если метод ИспользованиеДоступно
// объекта СистемаВзаимодействия возвращает Истина и
// использование не заблокировано администратором.
// 
// Возвращаемое значение:
//   Булево
//
Функция ОбсужденияДоступны() Экспорт
	Возврат ОбсужденияСлужебный.Подключены();
КонецФункции

// Формирует соответствие между идентификаторами пользователей системы взаимодействия
// и элементами справочника Пользователи.
//
// Параметры:
//   ПользователиСистемыВзаимодействия - Массив из ИдентификаторПользователяСистемыВзаимодействия
//                                     - КоллекцияИдентификаторовПользователейСистемыВзаимодействия 
// 
// Возвращаемое значение:
//   Соответствие из КлючИЗначение:
//   * Ключ - ИдентификаторПользователяСистемыВзаимодействия
//   * Значение - см. ПользовательИнформационнойБазы
//
Функция ПользователиИнформационнойБазы(ПользователиСистемыВзаимодействия)Экспорт
	ТипыВходныхПараметров = Новый Массив;
	ТипыВходныхПараметров.Добавить(Тип("КоллекцияИдентификаторовПользователейСистемыВзаимодействия"));
	ТипыВходныхПараметров.Добавить(Тип("Массив"));
 	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр("ПользователиИнформационнойБазы",
 		"ПользователиСистемыВзаимодействия",
 		ПользователиСистемыВзаимодействия,
 		ТипыВходныхПараметров);

	Результат = Новый Соответствие;
	Ошибки = Новый Массив;
	Для каждого Идентификатор Из ПользователиСистемыВзаимодействия Цикл
		Попытка
			Результат.Вставить(Идентификатор, ПользовательИнформационнойБазы(Идентификатор));
		Исключение
			Ошибки.Добавить(ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			Результат.Вставить(Идентификатор, Неопределено);
		КонецПопытки;
	КонецЦикла;
	
	Если Ошибки.Количество() > 0 Тогда
	
		ЗаписьЖурналаРегистрации(ОбсужденияСлужебный.СобытиеЖурналаРегистрации(
			НСтр("ru='Пользователи информационной базы'", ОбщегоНазначения.КодОсновногоЯзыка())),
			УровеньЖурналаРегистрации.Ошибка,,,
			СтрСоединить(Ошибки, Символы.ПС + Символы.ПС));
	
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

// Выполняет поиск элемента справочника Пользователи по идентификатору пользователя Системы Взаимодействия.
//
// Выбрасывает исключение, если пользователь не был найден.
//
// Параметры:
//   ПользовательСистемыВзаимодействия - ИдентификаторПользователяСистемыВзаимодействия.
//
// Возвращаемое значение:
//   СправочникСсылка.Пользователи
//
Функция ПользовательИнформационнойБазы(ПользовательСистемыВзаимодействия) Экспорт
	Результат = Неопределено;
	
	ПользовательСВ = СистемаВзаимодействия.ПолучитьПользователя(ПользовательСистемыВзаимодействия);
	Результат = Справочники.Пользователи.НайтиПоРеквизиту("ИдентификаторПользователяИБ", ПользовательСВ.ИдентификаторПользователяИнформационнойБазы);
	Если НЕ ЗначениеЗаполнено(Результат) Тогда
		
		ШаблонОшибки = НСтр("ru='Не удалось получить пользователя информационной базы по идентификатору пользователя системы взаимодействия (%1)'");
		ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонОшибки, Строка(ПользовательСистемыВзаимодействия));
		ВызватьИсключение ОписаниеОшибки;
		
	КонецЕсли;	
	
	Возврат Результат;
КонецФункции

// Формирует соответствие между элементами справочника Пользователи
// и идентификаторами пользователей системы взаимодействия.
//  
// Если пользователь не найден, то будет попытка создать пользователя системы взаимодействия.
// Если пользователь не найден и при создании нового пользователя было выброшено исключение,
// то возвращается Неопределено.
//
// Параметры:
//   ПользователиИнформационнойБазы - Массив из СправочникСсылка.Пользователи
// 
// Возвращаемое значение:
//   Соответствие из КлючИЗначение:
//   * Ключ - СправочникСсылка.Пользователи
//   * Значение - ПользовательСистемыВзаимодействия
//
Функция ПользователиСистемыВзаимодействия(ПользователиИнформационнойБазы) Экспорт
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		"ПользователиСистемыВзаимодействия",
 		"ПользователиИнформационнойБазы",
 		ПользователиИнформационнойБазы,
 		Тип("Массив"));
	
	Результат = Новый Соответствие;
	Ошибки = Новый Массив;

	Для каждого Пользователь Из ПользователиИнформационнойБазы Цикл
		
		Попытка
			Результат.Вставить(Пользователь, ПользовательСистемыВзаимодействия(Пользователь));
		Исключение
			Ошибки.Добавить(ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			Результат.Вставить(Пользователь, Неопределено);
		КонецПопытки;
		
	КонецЦикла;
	
	Если Ошибки.Количество() > 0 Тогда
		
		ЗаписьЖурналаРегистрации(ОбсужденияСлужебный.СобытиеЖурналаРегистрации(
			НСтр("ru='Пользователи системы взаимодействия'", ОбщегоНазначения.КодОсновногоЯзыка())),
			УровеньЖурналаРегистрации.Ошибка,,,
			СтрСоединить(Ошибки, Символы.ПС));
		
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

// Получает идентификатор пользователя системы взаимодействия.
// Если пользователь не найден, то будет выполнена попытка создать нового пользователя.
// 
// Выбрасывает исключение, если:
// - не удалось получить идентификатор пользователя информационной базы;
// - не удалось создать пользователя системы Взаимодействия.
//
// Параметры:
//  Пользователь - СправочникСсылка.Пользователи
//               - СправочникОбъект.Пользователи
//
//  ТолькоИдентификатор - Булево - если указать Истина, то возвращается не пользователь,
//                                 а идентификатор пользователя, что быстрее.
//
// Возвращаемое значение:
//   ПользовательСистемыВзаимодействия - если ТолькоИдентификатор = Ложь.
//   ИдентификаторПользователяСистемыВзаимодействия - если ТолькоИдентификатор = Истина.
//
Функция ПользовательСистемыВзаимодействия(Пользователь, ТолькоИдентификатор = Ложь) Экспорт
	
	ЭтоТекущийПользователь = Пользователь = Пользователи.АвторизованныйПользователь();
	Если ЭтоТекущийПользователь Тогда
		ИдентификаторПользователяИнформационнойБазы = ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор;
	Иначе
		УстановитьПривилегированныйРежим(Истина);
		ИдентификаторПользователяИнформационнойБазы = ?(ТипЗнч(Пользователь) = Тип("СправочникОбъект.Пользователи"),
			Пользователь.ИдентификаторПользователяИБ,
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
				Пользователь, "ИдентификаторПользователяИБ"));
		УстановитьПривилегированныйРежим(Ложь);
		
		Если Не ЗначениеЗаполнено(ИдентификаторПользователяИнформационнойБазы) Тогда
			Если Пользователь = Пользователи.СсылкаНеуказанногоПользователя() Тогда
				ИдентификаторПользователяИнформационнойБазы = ПользователиИнформационнойБазы.НайтиПоИмени("").УникальныйИдентификатор;
			Иначе
				ШаблонОшибки = НСтр("ru='Не удалось получить идентификатор пользователя (%1)'");
				ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					ШаблонОшибки,
					Строка(Пользователь));
					
				ВызватьИсключение ОписаниеОшибки;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Результат = Неопределено;
	ОшибкаПолучениеИдентификатораСВ = "";
	Попытка
		Если ЭтоТекущийПользователь Тогда
			ИдентификаторПользователяСВ = СистемаВзаимодействия.ИдентификаторТекущегоПользователя();
		Иначе
			ИдентификаторПользователяСВ = СистемаВзаимодействия.ПолучитьИдентификаторПользователя(
				ИдентификаторПользователяИнформационнойБазы);
		КонецЕсли;
		Если ТолькоИдентификатор Тогда
			Возврат ИдентификаторПользователяСВ;
		КонецЕсли;
		Результат = СистемаВзаимодействия.ПолучитьПользователя(ИдентификаторПользователяСВ);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Если ЭтоОшибкаУстановкиСоединенияССерверомВзаимодействия(ИнформацияОбОшибке) Тогда
			ВызватьИсключение;
		КонецЕсли;
		ЕстьСоединениеССерверомВзаимодействия = Истина;
		Попытка
			СистемаВзаимодействия.ПолучитьТипыВнешнихСистем();
		Исключение
			ЕстьСоединениеССерверомВзаимодействия = Ложь;
		КонецПопытки;
		Если Не ЕстьСоединениеССерверомВзаимодействия Тогда
			ВызватьИсключение;
		КонецЕсли;
		ОшибкаПолучениеИдентификатораСВ = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	КонецПопытки;
	
	Если Результат = Неопределено Тогда
		
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			Результат = НовыйПользовательСистемыВзаимодействия(Пользователь);
			УстановитьПривилегированныйРежим(Ложь);
		Исключение
			Ошибка = ИнформацияОбОшибке();
			ОписаниеОшибки = ?(Не ЗначениеЗаполнено(ОшибкаПолучениеИдентификатораСВ), "",
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Не удалось получить идентификатор пользователя системы взаимодействия для пользователя %1 (%2)
					           |по причине:
					           |%3'"),
					Строка(Пользователь),
					Строка(ИдентификаторПользователяИнформационнойБазы),
					ОшибкаПолучениеИдентификатораСВ)
				+ Символы.ПС + Символы.ПС);
			ОписаниеОшибки = ОписаниеОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Не удалось создать пользователя системы взаимодействия для пользователя %1 (%2)
					           |по причине:
					           |%3'"),
					Строка(Пользователь),
					Строка(ИдентификаторПользователяИнформационнойБазы),
					ОбработкаОшибок.ПодробноеПредставлениеОшибки(Ошибка));
			ЗаписьЖурналаРегистрации(ОбсужденияСлужебный.СобытиеЖурналаРегистрации(),
				УровеньЖурналаРегистрации.Ошибка,,,
				ОписаниеОшибки);
			ВызватьИсключение;
		КонецПопытки;
		
	КонецЕсли;
	
	Если ТолькоИдентификатор Тогда
		Возврат Результат.Идентификатор;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Обновляет дополнительную информацию пользователя системы взаимодействия.
// Например, телефон и адрес электронной почты.
// Если пользователь системы взаимодействия еще не создан, то будет создан новый пользователь
// системы взаимодействия.
//
// Выбрасывает исключение, если обновить пользователя системы взаимодействия не удалось.
//
// Параметры:
//   Пользователь - СправочникСсылка.Пользователи
//                - СправочникОбъект.Пользователи
//
Процедура ОбновитьПользователяВСистемеВзаимодействия(Пользователь) Экспорт
	
	Если Не СистемаВзаимодействийПодключена() Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		ПользовательСВ = ПользовательСистемыВзаимодействия(Пользователь);
		ОписаниеПользователя = ОписаниеПользователя(Пользователь);
		ОбновитьОписаниеПользователяВСистемеВзаимодействия(
			ПользовательСВ,
			ОписаниеПользователя);
	Исключение
		ОписаниеОшибки = НСтр("ru='Не удалось обновить пользователя системы взаимодействия.'");
		Ошибка = ИнформацияОбОшибке();
		ЗаписьЖурналаРегистрации(ОбсужденияСлужебный.СобытиеЖурналаРегистрации(
			НСтр("ru='Обновить описание в системе взаимодействия'", ОбщегоНазначения.КодОсновногоЯзыка())),
			УровеньЖурналаРегистрации.Ошибка,
			Пользователь.Метаданные(),
			Пользователь.Ссылка,
			ОписаниеОшибки + Символы.ПС + ОбработкаОшибок.ПодробноеПредставлениеОшибки(Ошибка));
	КонецПопытки;
	
КонецПроцедуры

// Формирует описание сообщение для отправки сообщения через процедуры
// и функции подсистемы Обсуждения.
//
// Параметры:
//   Текст - Строка - текст сообщения системы Взаимодействия
//         - ФорматированнаяСтрока
//
// Возвращаемое значение:
//   Структура:
//   * Текст - ФорматированнаяСтрока
//   * Вложения - Массив из см. ОписаниеВложения
//   * Данные - Неопределено - см. синтакс-помощник СообщениеСистемыВзаимодействия
//   * Действия - СписокЗначений - см. синтакс-помощник СообщениеСистемыВзаимодействия
//
Функция ОписаниеСообщения(Знач Текст) Экспорт
	Описание = Новый Структура;
	
	Если ТипЗнч(Текст) = Тип("Строка") Тогда
		Текст = Новый ФорматированнаяСтрока(Текст);
	КонецЕсли;
	
	Описание.Вставить("Текст", Текст);
	Описание.Вставить("Вложения", Новый Массив);
	Описание.Вставить("Данные", Неопределено);
	Описание.Вставить("Действия", Новый СписокЗначений);
	Возврат Описание;
КонецФункции

// Формирует описание вложения для отправки сообщения через процедуры
// и функции подсистемы Обсуждения.
//
// Параметры:
//   Поток - Поток - поток, из которого будет создано вложение системы Взаимодействия.
//         - ПотокВПамяти
//         - ФайловыйПоток
//   Наименование - Строка - имя вложения.
// 
// Возвращаемое значение:
//   Структура:
//   * Поток - Поток - поток, из которого будет создано вложение системы взаимодействия.
// 			- ПотокВПамяти
// 			- ФайловыйПоток
//   * Наименование - Строка
//   * ТипСодержимого - Строка
//   * Отображаемое - Булево - значение по умолчанию Истина
//
Функция ОписаниеВложения(Поток, Наименование) Экспорт

	Описание = Новый Структура;
	Описание.Вставить("Поток", Поток);
	Описание.Вставить("Наименование", Наименование);
	Описание.Вставить("ТипСодержимого", "");
	Описание.Вставить("Отображаемое", Истина);
	Возврат Описание;

КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Только для повышения производительности не должно влиять на функциональность,
// так как работает негарантированно.
// 
// Параметры:
//  ИнформацияОбОшибке - ИнформацияОбОшибке
// 
// Возвращаемое значение:
//  Булево
//
Функция ЭтоОшибкаУстановкиСоединенияССерверомВзаимодействия(ИнформацияОбОшибке) Экспорт
	
	СтрокиНаРазныхЯзыках = Новый Массив;
	
	// АПК:1036-выкл, АПК:1297-выкл, АПК:1405-выкл - не локализуется, строки на других языках уже строго определены.
	
	СтрокиНаРазныхЯзыках.Добавить(
	"az = 'Qarşılıqlı fəaliyyət sistmei qeydə alınmayıb';
	|en = 'The collaboration system is not registered';
	|hy = 'Փոխազդեցության համակարգը գրանցված չէ';
	|bg = 'Системата за взаимодействия не е регистрирана';
	|hu = 'Az interaktív rendszer nincs regisztrálva';
	|vi = 'Chưa ghi nhận hệ thống tương tác';
	|el = 'Το σύστημα αλληλεπίδρασης δεν έχει καταχωρηθεί';
	|ka = 'კომუნიკაციის სისტემა არ არის დარეგისტრირებული';
	|el = 'Το σύστημα αλληλεπίδρασης δεν έχει καταχωρηθεί';
	|it = 'Il sistema di interoperabilità non è registrato';
	|kk = 'Өзара әрекет ету жүйесі тіркелмеген';
	|zh = '交互系统没有启动';
	|lv = 'Mijiedarbības sistēma nav reģistrēta';
	|lt = 'Sąveikos sistema neužregistruota';
	|de = 'Interaktionssystem nicht registriert';
	|pl = 'System współpracy nie został zarejestrowany';
	|ro = 'Sistemul de interacţiune nu este înregistrat';
	|ru = 'Система взаимодействия не зарегистрирована';
	|tr = 'Etkileşim sistemine kayıtlı değil';
	|uk = 'Система взаємодії не зареєстрована';
	|fr = 'Le système d’interaction n’est pas enregistré'"); // @Non-NLS
	
	СтрокиНаРазныхЯзыках.Добавить(
	"az = 'Невозможно установить соединение с сервером системы взаимодействия';
	|en = 'Cannot connect to the collaboration system server';
	|hy = 'Невозможно установить соединение с сервером системы взаимодействия';
	|bg = 'Невозможно установить соединение с сервером системы взаимодействия';
	|hu = 'Невозможно установить соединение с сервером системы взаимодействия';
	|vi = 'Невозможно установить соединение с сервером системы взаимодействия';
	|el = 'Невозможно установить соединение с сервером системы взаимодействия';
	|ka = 'Невозможно установить соединение с сервером системы взаимодействия';
	|el = 'Невозможно установить соединение с сервером системы взаимодействия';
	|it = 'Невозможно установить соединение с сервером системы взаимодействия';
	|kk = 'Невозможно установить соединение с сервером системы взаимодействия';
	|zh = 'Невозможно установить соединение с сервером системы взаимодействия';
	|lv = 'Невозможно установить соединение с сервером системы взаимодействия';
	|lt = 'Невозможно установить соединение с сервером системы взаимодействия';
	|de = 'Невозможно установить соединение с сервером системы взаимодействия';
	|pl = 'Невозможно установить соединение с сервером системы взаимодействия';
	|ro = 'Невозможно установить соединение с сервером системы взаимодействия';
	|ru = 'Невозможно установить соединение с сервером системы взаимодействия';
	|tr = 'Невозможно установить соединение с сервером системы взаимодействия';
	|uk = 'Невозможно установить соединение с сервером системы взаимодействия';
	|fr = 'Невозможно установить соединение с сервером системы взаимодействия'"); // @Non-NLS
	
	// АПК:1036-вкл, АПК:1297-вкл, АПК:1405-вкл
	
	КраткоеПредставлениеОшибки = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
	
	Для Каждого СтрокаНаРазныхЯзыках Из СтрокиНаРазныхЯзыках Цикл
		//@skip-check bsl-nstr-string-literal-format
		СтрокаПоиска = НСтр(СтрокаНаРазныхЯзыках);
		Если ЗначениеЗаполнено(СтрокаПоиска)
		   И СтрНачинаетсяС(КраткоеПредставлениеОшибки, СтрокаПоиска) Тогда
			Возврат Истина;
		КонецЕсли;
		//@skip-check bsl-nstr-string-literal-format
		СтрокаПоиска = НСтр(СтрокаНаРазныхЯзыках, "ru");
		Если ЗначениеЗаполнено(СтрокаПоиска)
		   И СтрНачинаетсяС(КраткоеПредставлениеОшибки, СтрокаПоиска) Тогда
			Возврат Истина;
		КонецЕсли;
		//@skip-check bsl-nstr-string-literal-format
		СтрокаПоиска = НСтр(СтрокаНаРазныхЯзыках, "en");
		Если ЗначениеЗаполнено(СтрокаПоиска)
		   И СтрНачинаетсяС(КраткоеПредставлениеОшибки, СтрокаПоиска) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбновитьОписаниеПользователяВСистемеВзаимодействия(ПользовательСВ, ОписаниеПользователя)
	
	Фотография = ОписаниеПользователя.Фотография;
	Если Фотография <> Неопределено Тогда
		ПользовательСВ.Картинка = Новый Картинка(Фотография);
	КонецЕсли;
	
	ПользовательСВ.АдресЭлектроннойПочты = ОписаниеПользователя.АдресЭлектроннойПочты;
	ПользовательСВ.НомерТелефона = ОписаниеПользователя.Телефон;
	ПользовательСВ.Заблокирован = ОписаниеПользователя.Недействителен ИЛИ ОписаниеПользователя.ПометкаУдаления;
	
	УстановитьПривилегированныйРежим(Истина);
	ПользовательСВ.Записать();
	
КонецПроцедуры

// Создает нового пользователя системы взаимодействий и заполняет его данными пользователя
// информационной базы.
//
// Выбрасывает исключение, если не удалось создать нового пользователя системы Взаимодействия.
//
// Параметры:
//   Пользователь - СправочникСсылка.Пользователи - пользователь, для которого будет создан
//													пользователь системы взаимодействия.
// Возвращаемое значение:
//   ПользовательСистемыВзаимодействия
//
Функция НовыйПользовательСистемыВзаимодействия(Пользователь)
	ОписаниеПользователя = ОписаниеПользователя(Пользователь);
	
	Если НЕ ЗначениеЗаполнено(ОписаниеПользователя.ИдентификаторПользователяИБ) Тогда
		ВызватьИсключение НСтр("ru='Не существует пользователь информационной базы'");
	КонецЕсли;
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
		ОписаниеПользователя.ИдентификаторПользователяИБ);
	ПользовательСВ = СистемаВзаимодействия.СоздатьПользователя(ПользовательИБ);
	
	ОбновитьОписаниеПользователяВСистемеВзаимодействия(ПользовательСВ, ОписаниеПользователя);
	
	Возврат ПользовательСВ;
КонецФункции

Функция ОписаниеПользователя(Пользователь)
	Возврат ПользователиСлужебный.ОписаниеПользователя(Пользователь);
КонецФункции

// Параметры:
//  ПолучателиПриемник - КоллекцияИдентификаторовПользователейСистемыВзаимодействия
//  ПолучателиИсточник - КоллекцияИдентификаторовПользователейСистемыВзаимодействия
//                     - Массив из ПользовательСистемыВзаимодействия
//
Процедура ДобавитьПолучателей(ПолучателиПриемник, ПолучателиИсточник)
	
	Если ПолучателиИсточник.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Получатель Из ПолучателиИсточник Цикл 
		Если ТипЗнч(Получатель) = Тип("ИдентификаторПользователяСистемыВзаимодействия") Тогда
			ПолучателиПриемник.Добавить(Получатель);
		ИначеЕсли ТипЗнч(Получатель) = Тип("ПользовательСистемыВзаимодействия") Тогда
			ПолучателиПриемник.Добавить(Получатель.Идентификатор);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
//  Автор	 - ИдентификаторПользователяСистемыВзаимодействия
//  Участник - ИдентификаторПользователяСистемыВзаимодействия
// 
// Возвращаемое значение:
//    ОбсуждениеСистемыВзаимодействия
//
Функция НеГрупповоеОбсуждениеМеждуПользователями(Автор, Участник)
	Обсуждение = Неопределено;
	
	Отбор = Новый ОтборОбсужденийСистемыВзаимодействия;
	Отбор.КонтекстноеОбсуждение = Ложь;
	Отбор.Групповое = Ложь;
	НайденныеОбсуждения = СистемаВзаимодействия.ПолучитьОбсуждения(Отбор);
	
	Для каждого ОтобранноеОбсуждение Из НайденныеОбсуждения Цикл
		Если ОтобранноеОбсуждение.Участники.Содержит(Участник) 
				И ОтобранноеОбсуждение.Участники.Содержит(Автор) Тогда
			
			Обсуждение = ОтобранноеОбсуждение;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если Обсуждение = Неопределено Тогда
		Обсуждение = СистемаВзаимодействия.СоздатьОбсуждение();
		Обсуждение.Отображаемое = Истина;
		Обсуждение.Групповое = Ложь;
		Обсуждение.Участники.Добавить(Автор);
		Обсуждение.Участники.Добавить(Участник);
		Обсуждение.Записать();
	КонецЕсли;
	
	Возврат Обсуждение;
КонецФункции

Функция СообщениеИзОписания(Автор, ИдентификаторОбсуждения, Получатели, Сообщение)
	
	СообщениеСВ = СистемаВзаимодействия.СоздатьСообщение(ИдентификаторОбсуждения);
	СообщениеСВ.Автор = Автор.Идентификатор;
	СообщениеСВ.Текст = Сообщение.Текст;
	СообщениеСВ.Данные = Сообщение.Данные;
	Для каждого Действие Из Сообщение.Действия Цикл
		СообщениеСВ.Действия.Добавить(Действие.Значение, Действие.Представление);
	КонецЦикла;
	
	ДобавитьПолучателей(СообщениеСВ.Получатели, Получатели);
	
	Для каждого Вложение Из Сообщение.Вложения Цикл
		СообщениеСВ.Вложения.Добавить(Вложение.Поток, Вложение.Наименование, Вложение.ТипСодержимого, 
			Вложение.Отображаемое);
	КонецЦикла;
		
	Возврат СообщениеСВ;

КонецФункции

#КонецОбласти