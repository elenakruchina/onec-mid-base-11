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
	
	ПериодДляРегистровНакопления = КонецПериода(ДобавитьМесяц(ТекущаяДатаСеанса(), -1));
	ПериодДляРегистровБухгалтерии = КонецПериода(ТекущаяДатаСеанса());
	
	Элементы.ПериодДляРегистровБухгалтерии.Доступность  = Параметры.РегБухгалтерии;
	Элементы.ПериодДляРегистровНакопления.Доступность = Параметры.РегНакопления;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПериодДляРегистровНакопленияПриИзменении(Элемент)
	
	ПериодДляРегистровНакопления = КонецПериода(ПериодДляРегистровНакопления);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодДляРегистровБухгалтерииПриИзменении(Элемент)
	
	ПериодДляРегистровБухгалтерии = КонецПериода(ПериодДляРегистровБухгалтерии);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	РезультатВыбора = Новый Структура("ПериодДляРегистровНакопления, ПериодДляРегистровБухгалтерии");
	ЗаполнитьЗначенияСвойств(РезультатВыбора, ЭтотОбъект);
	
	ОповеститьОВыборе(РезультатВыбора);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция КонецПериода(Дата)
	
	Возврат КонецДня(КонецМесяца(Дата));
	
КонецФункции

#КонецОбласти
