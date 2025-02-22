///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область СлужебныеПроцедурыИФункции

Функция ФоновоеЗаданиеЗавершено(ИдентификаторЗадания) Экспорт
	
	ФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	Если ФоновоеЗадание = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если ФоновоеЗадание.Состояние <> СостояниеФоновогоЗадания.Активно Тогда
		Возврат Истина;
	КонецЕсли;
	
	ФоновоеЗадание = ФоновоеЗадание.ОжидатьЗавершенияВыполнения(3);
	
	Возврат ФоновоеЗадание.Состояние <> СостояниеФоновогоЗадания.Активно;
	
КонецФункции

#КонецОбласти
