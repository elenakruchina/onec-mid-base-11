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
	ДобавитьЦвета("ЧерноБелые", "000000,444444,666666,999999,CCCCCC,EEEEEE,F3F3F3,FFFFFF");
	ДобавитьЦвета("Основные", "EB3541,EB9635,EBDE35,41EB35,35EBDE,3541EB,9635EB,DE35EB");
	ДобавитьЦвета("Остальные", "E5717C,F9AC75,FFCE73,A1CA86,81B3B7,79BAE1,9085C9,C884AE");
	ДобавитьЦвета("Остальные", "D31225,EB8A46,F5B640,7EB15C,539399,4B9CCD,6B5BB0,AF5A8D");
	ДобавитьЦвета("Остальные", "B10E1E,CB5B11,D78F0A,518B2B,246B72,1871AA,3B2B8A,892A61");
	ДобавитьЦвета("Остальные", "680910,7B310B,845008,2E4D17,133B3F,0E3D63,1D164C,4B1635");
КонецПроцедуры 

&НаСервере
Процедура ДобавитьЦвета(ИмяГруппы, СтрокаЦветов)
	
	Размещение = Элементы.Найти(ИмяГруппы);
	
	Если Размещение = Неопределено Тогда
		Размещение = Элементы.Добавить(ИмяГруппы, Тип("ГруппаФормы"));
		Размещение.Вид = ВидГруппыФормы.ОбычнаяГруппа;
		Размещение.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
		Размещение.ОтображатьЗаголовок = Ложь;
		Элементы.Переместить(Размещение, ЭтотОбъект, Элементы.ГруппаДополнительныеДействия);
		Размещение.ВертикальныйИнтервал = ИнтервалМеждуЭлементамиФормы.Нет;
	КонецЕсли;
	
	Счетчик = 0;
	
	Пока Элементы.Найти("Группа"+Формат(Счетчик, "ЧГ=0;")) <> Неопределено Цикл
		Счетчик = Счетчик + 1;
	КонецЦикла;
	
	ГруппаЦветов = Элементы.Добавить("Группа"+Формат(Счетчик, "ЧГ=0;"), Тип("ГруппаФормы"), Размещение);
	ГруппаЦветов.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	ГруппаЦветов.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	ГруппаЦветов.ОтображатьЗаголовок = Ложь;
	ГруппаЦветов.ГоризонтальныйИнтервал = ИнтервалМеждуЭлементамиФормы.Нет;
	ГруппаЦветов.ВертикальныйИнтервал = ИнтервалМеждуЭлементамиФормы.Нет;
	
	МассивЦветов = СтрРазделить(СтрокаЦветов, ",");
	
	Для Каждого Цвет Из МассивЦветов Цикл
		ДекорацияЦвета = Элементы.Добавить("Цвет_"+Цвет, Тип("ДекорацияФормы"), ГруппаЦветов);
		ДекорацияЦвета.Вид = ВидДекорацииФормы.Надпись;
		Красный = ЧислоИзШестнадцатеричнойСтроки("0x" + Сред(Цвет, 1, 2));
		Зеленый = ЧислоИзШестнадцатеричнойСтроки("0x" + Сред(Цвет, 3, 2));
		Синий = ЧислоИзШестнадцатеричнойСтроки("0x" + Сред(Цвет, 5, 2));
		// @skip-check new-color - алгоритмическое создание цветов для палитры
		ДекорацияЦвета.ЦветФона = Новый Цвет(Красный, Зеленый, Синий); 
		ДекорацияЦвета.Заголовок = "  ";
		ДекорацияЦвета.Ширина = 4;
		ДекорацияЦвета.Высота = 2;
		ДекорацияЦвета.Рамка = Новый Рамка(ТипРамкиЭлементаУправления.Одинарная);
		ДекорацияЦвета.ЦветРамки = ЦветаСтиля.ЦветФонаФормы;
		ДекорацияЦвета.УстановитьДействие("Нажатие", "Подключаемый_ЦветНажатие");
		ДекорацияЦвета.Гиперссылка = Истина;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ОчиститьЦвет(Команда)
	Закрыть(Новый Цвет());
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура Подключаемый_ЦветНажатие(Элемент)
	Закрыть(Элемент.ЦветФона);
КонецПроцедуры

&НаКлиенте
Процедура ДругиеЦветаНажатие(Элемент)
	Закрыть("ДругиеЦвета");
КонецПроцедуры


#КонецОбласти
